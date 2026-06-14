import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/formatters.dart';
import '../features/admin/admin_page.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/community/presentation/screens/community_detail_screen.dart';
import '../features/community/presentation/screens/community_screen.dart';
import '../features/community/presentation/screens/create_post_screen.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/gacha/gacha_page.dart';
import '../features/gacha/presentation/gacha_history_screen.dart';
import '../features/gacha/presentation/gacha_providers.dart';
import '../features/inventory/inventory_page.dart';
import '../features/ranking/ranking_page.dart';
import '../features/statistics/statistics_page.dart';
import 'router.dart';
import 'theme.dart';

class GachaLogApp extends StatelessWidget {
  const GachaLogApp({super.key});

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AppRoot()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/gacha/history',
        builder: (context, state) => const GachaHistoryScreen(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePostScreen(),
          ),
          GoRoute(
            path: 'posts/:postId',
            builder: (context, state) => CommunityDetailScreen(
              postId: int.parse(state.pathParameters['postId']!),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => CreatePostScreen(
                  postId: int.parse(state.pathParameters['postId']!),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Astra Archive',
      theme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  AppPage _page = AppPage.dashboard;

  void _selectPage(AppPage page) {
    if (page == AppPage.community) {
      context.go('/community');
      return;
    }
    setState(() => _page = page);
    if (MediaQuery.sizeOf(context).width < 900) {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(authSessionProvider).value != null;
    final banner = isAuthenticated
        ? ref.watch(gachaBannersProvider).value?.firstOrNull
        : null;
    final history = isAuthenticated
        ? ref.watch(gachaHistoryProvider).value
        : null;
    final crystals = banner?.walletBalance ?? 0;
    final pity = banner?.pityCount ?? 0;
    final totalDraws =
        history?.items.fold<int>(0, (total, draw) => total + draw.drawCount) ??
        0;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: AppColors.surface,
              child: SafeArea(
                child: AppNavigation(page: _page, onTap: _selectPage),
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 240,
              child: AppNavigation(page: _page, onTap: _selectPage),
            ),
          Expanded(
            child: Column(
              children: [
                TopBar(crystals: crystals, showMenu: !isDesktop),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildPage(
                      crystals: crystals,
                      totalDraws: totalDraws,
                      pity: pity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required int crystals,
    required int totalDraws,
    required int pity,
  }) {
    return switch (_page) {
      AppPage.dashboard => DashboardPage(
        key: const ValueKey('dashboard'),
        crystals: crystals,
        totalDraws: totalDraws,
        pity: pity,
        onDraw: () => _selectPage(AppPage.gacha),
      ),
      AppPage.gacha => const GachaPage(key: ValueKey('gacha')),
      AppPage.inventory => const InventoryPage(key: ValueKey('inventory')),
      AppPage.statistics => const StatisticsPage(key: ValueKey('statistics')),
      AppPage.ranking => const RankingPage(key: ValueKey('ranking')),
      AppPage.community => const SizedBox.shrink(),
      AppPage.admin => const AdminPage(key: ValueKey('admin')),
    };
  }
}

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key, required this.page, required this.onTap});

  final AppPage page;
  final ValueChanged<AppPage> onTap;

  @override
  Widget build(BuildContext context) {
    const entries = [
      (AppPage.dashboard, Icons.grid_view_rounded, 'Dashboard'),
      (AppPage.gacha, Icons.auto_awesome, 'Gacha'),
      (AppPage.inventory, Icons.inventory_2_outlined, 'Inventory'),
      (AppPage.statistics, Icons.query_stats, 'Statistics'),
      (AppPage.ranking, Icons.emoji_events_outlined, 'Ranking'),
      (AppPage.community, Icons.forum_outlined, 'Community'),
      (AppPage.admin, Icons.admin_panel_settings_outlined, 'Admin'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 26, 20, 28),
            child: Row(
              children: [
                BrandMark(),
                SizedBox(width: 12),
                Text(
                  'ASTRA\nARCHIVE',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: NavigationTile(
                icon: entry.$2,
                label: entry.$3,
                selected: entry.$1 == page,
                onTap: () => onTap(entry.$1),
              ),
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'SYSTEM STATUS\nAll services operational',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                height: 1.7,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .35),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, size: 20),
    );
  }
}

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: .16)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.text : AppColors.muted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.crystals, required this.showMenu});

  final int crystals;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  formatNumber(crystals),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text('K', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
