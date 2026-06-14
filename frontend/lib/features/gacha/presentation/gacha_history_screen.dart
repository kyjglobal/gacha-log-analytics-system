import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import 'gacha_providers.dart';

class GachaHistoryScreen extends ConsumerWidget {
  const GachaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(gachaHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('가챠 이력')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(gachaHistoryProvider),
            child: Text('이력을 불러오지 못했습니다.\n$error\n다시 시도'),
          ),
        ),
        data: (page) => page.items.isEmpty
            ? const Center(child: Text('가챠 이력이 없습니다.'))
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(gachaHistoryProvider);
                  await ref.read(gachaHistoryProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final draw = page.items[index];
                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          '${draw.bannerName} · ${draw.drawCount}회 소환',
                        ),
                        subtitle: Text(
                          '세션 #${draw.sessionId} · 천장 '
                          '${draw.pityBefore} → ${draw.pityAfter}',
                        ),
                        trailing: Text(
                          '-${draw.totalCost}',
                          style: const TextStyle(color: AppColors.warning),
                        ),
                        children: draw.results
                            .map(
                              (result) => ListTile(
                                leading: const Icon(Icons.auto_awesome),
                                title: Text(result.itemName),
                                subtitle: Text(
                                  '${result.rarity} · 공식 확률 '
                                  '${(result.officialProbability * 100).toStringAsFixed(2)}%',
                                ),
                                trailing: result.wasPityApplied
                                    ? const Chip(label: Text('천장'))
                                    : null,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
