import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/formatters.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/widgets/status_badge.dart';
import '../auth/presentation/auth_providers.dart';
import 'domain/statistics_models.dart';
import 'presentation/statistics_providers.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null) {
      return PageCanvas(
        title: 'Probability Analytics',
        subtitle: '로그인 후 개인 확률과 전체 사용자 확률을 비교할 수 있습니다.',
        children: [
          Center(
            child: FilledButton.icon(
              onPressed: () => context.push('/auth'),
              icon: const Icon(Icons.login),
              label: const Text('로그인'),
            ),
          ),
        ],
      );
    }

    final statistics = ref.watch(probabilityStatisticsProvider);
    return statistics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => PageCanvas(
        title: 'Probability Analytics',
        subtitle: '확률 통계를 불러오지 못했습니다.',
        children: [
          Center(
            child: TextButton(
              onPressed: () => ref.invalidate(probabilityStatisticsProvider),
              child: Text('$error\n다시 시도'),
            ),
          ),
        ],
      ),
      data: (data) => PageCanvas(
        title: 'Probability Analytics',
        subtitle: '${data.bannerName}의 공식·개인·전체 사용자 획득 확률을 비교합니다.',
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => ref.invalidate(probabilityStatisticsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
        children: [
          ResponsiveGrid(
            minItemWidth: 220,
            children: [
              MetricCard(
                label: '개인 표본',
                value: formatNumber(data.personalTotalDraws),
                detail: '검증된 개인 가챠 결과',
                icon: Icons.person_search_outlined,
                accent: AppColors.secondary,
              ),
              MetricCard(
                label: '전체 표본',
                value: formatNumber(data.communityTotalDraws),
                detail: '삭제되지 않은 전체 결과',
                icon: Icons.groups_outlined,
                accent: AppColors.primary,
              ),
              MetricCard(
                label: 'Luck Score',
                value: data.luckScore.toStringAsFixed(1),
                detail: _luckScoreDescription(data.luckScore),
                icon: Icons.auto_graph,
                accent: _luckScoreColor(data.luckScore),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ProbabilityTable(statistics: data),
        ],
      ),
    );
  }

  String _luckScoreDescription(double score) {
    if (score == 0) return '표본이 필요합니다';
    if (score >= 110) return '공식 기대값보다 높음';
    if (score <= 90) return '공식 기대값보다 낮음';
    return '공식 기대값과 유사';
  }

  Color _luckScoreColor(double score) {
    if (score >= 110) return AppColors.success;
    if (score > 0 && score <= 90) return AppColors.danger;
    return AppColors.warning;
  }
}

class ProbabilityTable extends StatelessWidget {
  const ProbabilityTable({super.key, required this.statistics});

  final ProbabilityStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: '등급별 확률 비교',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('등급')),
            DataColumn(label: Text('공식 확률')),
            DataColumn(label: Text('개인 확률')),
            DataColumn(label: Text('개인 획득')),
            DataColumn(label: Text('전체 확률')),
            DataColumn(label: Text('편차')),
          ],
          rows: statistics.rarities
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(
                      StatusBadge(
                        _rarityLabel(row.rarity),
                        _rarityColor(row.rarity),
                      ),
                    ),
                    DataCell(Text(_percent(row.officialProbability))),
                    DataCell(Text(_percent(row.personalProbability))),
                    DataCell(Text(formatNumber(row.personalCount))),
                    DataCell(Text(_percent(row.communityProbability))),
                    DataCell(
                      Text(
                        _deviation(row.personalDeviation),
                        style: TextStyle(
                          color: row.personalDeviation >= 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _percent(double value) => '${(value * 100).toStringAsFixed(2)}%';

  String _deviation(double value) {
    final points = value * 100;
    final sign = points > 0 ? '+' : '';
    return '$sign${points.toStringAsFixed(2)}%p';
  }

  String _rarityLabel(String rarity) {
    return switch (rarity) {
      'mythic' => 'Mythic',
      'legendary' => 'Legendary',
      'epic' => 'Epic',
      'rare' => 'Rare',
      _ => 'Common',
    };
  }

  Color _rarityColor(String rarity) {
    return switch (rarity) {
      'mythic' => AppColors.warning,
      'legendary' => const Color(0xFFFF8A65),
      'epic' => AppColors.primary,
      'rare' => AppColors.secondary,
      _ => AppColors.muted,
    };
  }
}
