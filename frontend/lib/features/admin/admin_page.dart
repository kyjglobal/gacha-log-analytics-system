import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/formatters.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../auth/presentation/auth_providers.dart';
import 'domain/admin_models.dart';
import 'presentation/admin_providers.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _searchController = TextEditingController();
  String? _search;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminGachaSessionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authSessionProvider).value?.user;
    if (currentUser?.role != 'admin') {
      return const PageCanvas(
        title: 'Admin Backoffice',
        subtitle: '관리자 권한이 필요한 화면입니다.',
        children: [Center(child: Icon(Icons.lock_outline, size: 64))],
      );
    }

    final dashboard = ref.watch(adminDashboardProvider);
    final users = ref.watch(adminUsersProvider(_search));
    final sessions = ref.watch(adminGachaSessionsProvider);
    return PageCanvas(
      title: 'Admin Backoffice',
      subtitle: '사용자, 가챠 로그, 인벤토리 조정을 관리합니다.',
      actions: [
        IconButton(
          tooltip: '새로고침',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      children: [
        dashboard.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('대시보드를 불러오지 못했습니다: $error'),
          data: (data) => ResponsiveGrid(
            minItemWidth: 210,
            children: [
              MetricCard(
                label: '전체 사용자',
                value: formatNumber(data.totalUsers),
                detail: '활성 ${formatNumber(data.activeUsers)}명',
                icon: Icons.people_outline,
                accent: AppColors.secondary,
              ),
              MetricCard(
                label: '정지·차단',
                value: formatNumber(data.suspendedUsers),
                detail: '접근 제한 사용자',
                icon: Icons.block_outlined,
                accent: AppColors.danger,
              ),
              MetricCard(
                label: '유효 추첨',
                value: formatNumber(data.totalDraws),
                detail: 'Soft Delete 제외',
                icon: Icons.auto_awesome,
                accent: AppColors.primary,
              ),
              MetricCard(
                label: '삭제 로그',
                value: formatNumber(data.deletedGachaSessions),
                detail: '감사 목적으로 보존',
                icon: Icons.delete_outline,
                accent: AppColors.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          title: '사용자 관리',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '이메일 또는 닉네임 검색',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) => setState(
                        () => _search = value.trim().isEmpty
                            ? null
                            : value.trim(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => setState(
                      () => _search = _searchController.text.trim().isEmpty
                          ? null
                          : _searchController.text.trim(),
                    ),
                    child: const Text('검색'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              users.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('사용자를 불러오지 못했습니다: $error'),
                data: (page) => Column(
                  children: page.items
                      .map(
                        (user) => AdminUserTile(
                          user: user,
                          onStatusChanged: (status) async {
                            await ref
                                .read(adminRepositoryProvider)
                                .updateUserStatus(user.id, status);
                            _refresh();
                          },
                          onAdjustInventory: () => _showInventoryDialog(user),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          title: '최근 가챠 로그',
          child: sessions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('로그를 불러오지 못했습니다: $error'),
            data: (page) => Column(
              children: page.items
                  .map(
                    (session) => ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text(
                        '#${session.id} ${session.userNickname} · '
                        '${session.drawCount}회',
                      ),
                      subtitle: Text(
                        '${session.bannerName} · 비용 ${session.totalCost}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Soft Delete',
                        onPressed: session.isDeleted
                            ? null
                            : () async {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .deleteGachaSession(session.id);
                                _refresh();
                              },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showInventoryDialog(AdminUser user) async {
    final itemController = TextEditingController();
    final quantityController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${user.nickname} 인벤토리 조정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '아이템 ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '조정 수량',
                helperText: '지급은 양수, 회수는 음수',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final itemId = int.tryParse(itemController.text);
              final delta = int.tryParse(quantityController.text);
              if (itemId == null || delta == null || delta == 0) return;
              await ref
                  .read(adminRepositoryProvider)
                  .adjustInventory(
                    userId: user.id,
                    itemId: itemId,
                    quantityDelta: delta,
                  );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _refresh();
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
    itemController.dispose();
    quantityController.dispose();
  }
}

class AdminUserTile extends StatelessWidget {
  const AdminUserTile({
    super.key,
    required this.user,
    required this.onStatusChanged,
    required this.onAdjustInventory,
  });

  final AdminUser user;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onAdjustInventory;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(user.nickname.characters.first)),
      title: Text('${user.nickname} · ${user.email}'),
      subtitle: Text(
        '재화 ${formatNumber(user.walletBalance)} · '
        '추첨 ${formatNumber(user.totalDraws)}회',
      ),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<String>(
            value: user.status,
            items: const [
              DropdownMenuItem(value: 'active', child: Text('활성')),
              DropdownMenuItem(value: 'suspended', child: Text('정지')),
              DropdownMenuItem(value: 'blocked', child: Text('차단')),
            ],
            onChanged: (value) {
              if (value != null && value != user.status) {
                onStatusChanged(value);
              }
            },
          ),
          IconButton(
            tooltip: '아이템 지급·회수',
            onPressed: onAdjustInventory,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
        ],
      ),
    );
  }
}
