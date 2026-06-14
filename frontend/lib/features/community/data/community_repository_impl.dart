import '../domain/community_category.dart';
import '../domain/community_comment.dart';
import '../domain/community_post.dart';
import '../domain/community_repository.dart';
import 'community_api_service.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._api);

  final CommunityApiService _api;

  @override
  Future<CommunityPostPage> getPosts({
    int page = 1,
    int size = 20,
    CommunityCategory? category,
    String? search,
  }) async {
    final json = await _api.getPosts(
      page: page,
      size: size,
      category: category,
      search: search,
    );
    return CommunityPostPage.fromJson(json);
  }

  @override
  Future<CommunityPost> getPost(int postId) async {
    return CommunityPost.fromJson(await _api.getPost(postId));
  }

  @override
  Future<CommunityPost> createPost({
    required String title,
    required String content,
    required CommunityCategory category,
    String? imageUrl,
  }) async {
    return CommunityPost.fromJson(
      await _api.createPost({
        'title': title,
        'content': content,
        'category': category.label,
        'image_url': imageUrl,
      }),
    );
  }

  @override
  Future<CommunityPost> updatePost({
    required int postId,
    required String title,
    required String content,
    required CommunityCategory category,
    String? imageUrl,
  }) async {
    return CommunityPost.fromJson(
      await _api.updatePost(postId, {
        'title': title,
        'content': content,
        'category': category.label,
        'image_url': imageUrl,
      }),
    );
  }

  @override
  Future<void> deletePost(int postId) => _api.deletePost(postId);

  @override
  Future<({bool liked, int likeCount})> toggleLike(int postId) async {
    final json = await _api.toggleLike(postId);
    return (liked: json['liked'] as bool, likeCount: json['like_count'] as int);
  }

  @override
  Future<List<CommunityComment>> getComments(int postId) async {
    final json = await _api.getComments(postId);
    return json
        .map((item) => CommunityComment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CommunityComment> createComment(int postId, String content) async {
    return CommunityComment.fromJson(await _api.createComment(postId, content));
  }

  @override
  Future<void> deleteComment(int commentId) {
    return _api.deleteComment(commentId);
  }
}
