import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/models/owned_item.dart';
import '../../shared/widgets/inventory_card.dart';
import '../auth/presentation/auth_providers.dart';
import 'domain/gacha_models.dart';
import 'presentation/gacha_providers.dart';

class GachaPage extends ConsumerWidget {
  const GachaPage({super.key});

  Future<void> _draw(
    BuildContext context,
    WidgetRef ref,
    GachaBanner banner,
    int count,
  ) async {
    final result = await ref
        .read(gachaDrawProvider.notifier)
        .draw(bannerId: banner.id, count: count);
    if (!context.mounted || result == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => DrawResultDialog(draw: result),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null) {
      return PageCanvas(
        title: 'Celestial Trace',
        subtitle: '로그인 후 서버에서 검증되는 가챠를 실행할 수 있습니다.',
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

    final banners = ref.watch(gachaBannersProvider);
    final drawState = ref.watch(gachaDrawProvider);
    return banners.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => PageCanvas(
        title: 'Celestial Trace',
        subtitle: '배너를 불러오지 못했습니다.',
        children: [
          Center(
            child: TextButton(
              onPressed: () => ref.invalidate(gachaBannersProvider),
              child: Text('$error\n다시 시도'),
            ),
          ),
        ],
      ),
      data: (items) {
        if (items.isEmpty) {
          return const PageCanvas(
            title: 'Celestial Trace',
            subtitle: '현재 활성화된 배너가 없습니다.',
            children: [],
          );
        }
        final banner = items.first;
        return PageCanvas(
          title: banner.name,
          subtitle: '재화 차감, 결과 기록, 인벤토리, 천장을 하나의 트랜잭션으로 처리합니다.',
          actions: [
            TextButton.icon(
              onPressed: () => context.push('/gacha/history'),
              icon: const Icon(Icons.history),
              label: const Text('가챠 이력'),
            ),
          ],
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 440),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF251447),
                    Color(0xFF101827),
                    Color(0xFF083344),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .55),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 72,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    banner.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '신화 기본 확률 ${_mythicRate(banner)}% · '
                    '${banner.pityThreshold}회 이내 확정',
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('천장 진행도'),
                            Text(
                              '${banner.pityCount} / ${banner.pityThreshold}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: banner.pityCount / banner.pityThreshold,
                            minHeight: 10,
                            backgroundColor: AppColors.surface,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '보유 재화 ${banner.walletBalance}',
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      DrawButton(
                        label: '1회 소환',
                        cost: banner.costPerDraw,
                        enabled:
                            !drawState.isLoading &&
                            banner.walletBalance >= banner.costPerDraw,
                        onPressed: () => _draw(context, ref, banner, 1),
                      ),
                      DrawButton(
                        label: '10회 소환',
                        cost: banner.costPerDraw * 10,
                        emphasized: true,
                        enabled:
                            !drawState.isLoading &&
                            banner.walletBalance >= banner.costPerDraw * 10,
                        onPressed: () => _draw(context, ref, banner, 10),
                      ),
                    ],
                  ),
                  if (drawState.hasError) ...[
                    const SizedBox(height: 16),
                    Text(
                      '소환 실패: ${drawState.error}',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _mythicRate(GachaBanner banner) {
    final rate = banner.pool
        .where((item) => item.rarity == 'mythic')
        .fold<double>(0, (sum, item) => sum + item.officialProbability);
    return (rate * 100).toStringAsFixed(2);
  }
}

class DrawButton extends StatelessWidget {
  const DrawButton({
    super.key,
    required this.label,
    required this.cost,
    required this.enabled,
    required this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final int cost;
  final bool enabled;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: emphasized ? AppColors.primary : AppColors.surfaceHigh,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('Cost $cost', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class DrawResultDialog extends StatelessWidget {
  const DrawResultDialog({super.key, required this.draw});

  final GachaDraw draw;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '소환 결과',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              Text('세션 #${draw.sessionId} · 잔액 ${draw.balanceAfter}'),
              const SizedBox(height: 22),
              Flexible(
                child: SingleChildScrollView(
                  child: ResponsiveGrid(
                    minItemWidth: 130,
                    children: draw.results
                        .map(
                          (result) => SizedBox(
                            height: 165,
                            child: InventoryCard(
                              item: OwnedItem(
                                result.itemName,
                                _rarity(result.rarity),
                                1,
                                Icons.auto_awesome,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ItemRarity _rarity(String rarity) {
    return switch (rarity) {
      'mythic' => ItemRarity.mythic,
      'legendary' => ItemRarity.legendary,
      'epic' => ItemRarity.epic,
      'rare' => ItemRarity.rare,
      _ => ItemRarity.common,
    };
  }
}
