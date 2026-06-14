import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_providers.dart';
import '../../data/community_api_service.dart';
import '../../data/community_repository_impl.dart';
import '../../domain/community_category.dart';
import '../../domain/community_comment.dart';
import '../../domain/community_post.dart';
import '../../domain/community_repository.dart';

final communityApiServiceProvider = Provider<CommunityApiService>((ref) {
  return CommunityApiService(ref.watch(apiClientProvider));
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(ref.watch(communityApiServiceProvider));
});

final communityPostsProvider =
    AsyncNotifierProvider<CommunityPostsNotifier, CommunityPostPage>(
      CommunityPostsNotifier.new,
    );

class CommunityPostsNotifier extends AsyncNotifier<CommunityPostPage> {
  CommunityCategory? _category;
  String? _search;

  @override
  Future<CommunityPostPage> build() {
    return ref.read(communityRepositoryProvider).getPosts();
  }

  Future<void> load({CommunityCategory? category, String? search}) async {
    _category = category;
    _search = search;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(communityRepositoryProvider)
          .getPosts(category: _category, search: _search),
    );
  }

  Future<void> refresh() => load(category: _category, search: _search);
}

final communityPostProvider = FutureProvider.autoDispose
    .family<CommunityPost, int>((ref, postId) {
      return ref.watch(communityRepositoryProvider).getPost(postId);
    });

final communityCommentsProvider = FutureProvider.autoDispose
    .family<List<CommunityComment>, int>((ref, postId) {
      return ref.watch(communityRepositoryProvider).getComments(postId);
    });
