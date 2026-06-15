import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/formatters.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../core/constants/display_text.dart';
import '../../core/network/error_message.dart';
import '../auth/presentation/auth_providers.dart';
import 'domain/ranking_models.dart';
import 'presentation/ranking_providers.dart';

class RankingPage extends ConsumerWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null) {
      return PageCanvas(
        title: '랭킹',
        subtitle: '로그인 후 검증된 가챠 로그 기반 랭킹을 확인할 수 있습니다.',
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

    final ranking = ref.watch(rankingBoardProvider);
    return ranking.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => PageCanvas(
        title: '랭킹',
        subtitle: '랭킹을 불러오지 못했습니다.',
        children: [
          Center(
            child: TextButton(
              onPressed: () => ref.invalidate(rankingBoardProvider),
              child: Text('${userErrorMessage(error)}\n다시 시도'),
            ),
          ),
        ],
      ),
      data: (board) => PageCanvas(
        title: '랭킹',
        subtitle: '${bannerDisplayName(board.bannerName)}의 행운 점수 순위입니다.',
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => ref.invalidate(rankingBoardProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
        children: [
          ResponsiveGrid(
            minItemWidth: 220,
            children: [
              MetricCard(
                label: '내 순위',
                value: board.myRank == null ? '-' : '#${board.myRank}',
                detail: board.myRank == null
                    ? '최소 표본을 충족하지 못했습니다'
                    : '전체 조건 충족 사용자 기준',
                icon: Icons.person_outline,
                accent: AppColors.secondary,
              ),
              MetricCard(
                label: '최소 표본',
                value: formatNumber(board.minimumDraws),
                detail: '랭킹 진입에 필요한 추첨 수',
                icon: Icons.rule,
                accent: AppColors.warning,
              ),
              MetricCard(
                label: '랭킹 사용자',
                value: formatNumber(board.entries.length),
                detail: '현재 표시 중인 사용자',
                icon: Icons.groups_outlined,
                accent: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          RankingList(board: board),
        ],
      ),
    );
  }
}

class RankingList extends StatelessWidget {
  const RankingList({super.key, required this.board});

  final RankingBoard board;

  @override
  Widget build(BuildContext context) {
    if (board.entries.isEmpty) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: Text('랭킹 조건을 충족한 사용자가 없습니다.')),
        ),
      );
    }
    return AppCard(
      title: '행운 점수 순위표',
      child: Column(
        children: [
          for (var index = 0; index < board.entries.length; index++) ...[
            RankingTile(entry: board.entries[index]),
            if (index < board.entries.length - 1)
              const Divider(color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class RankingTile extends StatelessWidget {
  const RankingTile({super.key, required this.entry});

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: entry.isCurrentUser
          ? AppColors.primary.withValues(alpha: .08)
          : Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.rank <= 3
              ? AppColors.primary
              : AppColors.surfaceHigh,
          child: Text('${entry.rank}'),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                entry.nickname,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (entry.isCurrentUser) ...[
              const SizedBox(width: 8),
              const Chip(label: Text('나')),
            ],
          ],
        ),
        subtitle: Text(
          '총 ${formatNumber(entry.totalDraws)}회 · '
          '신화 ${entry.mythicCount}개 '
          '(${(entry.mythicProbability * 100).toStringAsFixed(2)}%)',
        ),
        trailing: Text(
          entry.luckScore.toStringAsFixed(1),
          style: TextStyle(
            color: entry.luckScore >= 100
                ? AppColors.success
                : AppColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
