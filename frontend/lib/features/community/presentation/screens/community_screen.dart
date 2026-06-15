import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/community_category.dart';
import '../providers/community_providers.dart';
import '../widgets/community_category_chip.dart';
import '../widgets/post_card.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _searchController = TextEditingController();
  CommunityCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    ref
        .read(communityPostsProvider.notifier)
        .load(category: _category, search: _searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityPostsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('확률 커뮤니티'),
        actions: [
          IconButton(
            tooltip: '홈',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
          IconButton(
            tooltip: '글 작성',
            onPressed: () => context.push('/community/create'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(communityPostsProvider.notifier).refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SearchBar(
                      controller: _searchController,
                      hintText: '제목 또는 내용 검색',
                      leading: const Icon(Icons.search),
                      onSubmitted: (_) => _load(),
                      trailing: [
                        IconButton(
                          onPressed: _load,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('전체'),
                            selected: _category == null,
                            onSelected: (_) {
                              setState(() => _category = null);
                              _load();
                            },
                          ),
                          const SizedBox(width: 8),
                          ...CommunityCategory.values.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CommunityCategoryChip(
                                category: category,
                                selected: category == _category,
                                onSelected: (_) {
                                  setState(() => _category = category);
                                  _load();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            posts.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: TextButton(
                    onPressed: _load,
                    child: Text('불러오지 못했습니다\n$error\n다시 시도'),
                  ),
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('등록된 게시글이 없습니다.')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: page.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final post = page.items[index];
                          return PostCard(
                            post: post,
                            onTap: () =>
                                context.push('/community/posts/${post.id}'),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/create'),
        icon: const Icon(Icons.add),
        label: const Text('글 작성'),
      ),
    );
  }
}
