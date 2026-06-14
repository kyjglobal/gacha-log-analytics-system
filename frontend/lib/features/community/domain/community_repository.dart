import 'community_category.dart';
import 'community_comment.dart';
import 'community_post.dart';

abstract interface class CommunityRepository {
  Future<CommunityPostPage> getPosts({
    int page = 1,
    int size = 20,
    CommunityCategory? category,
    String? search,
  });

  Future<CommunityPost> getPost(int postId);

  Future<CommunityPost> createPost({
    required String title,
    required String content,
    required CommunityCategory category,
    String? imageUrl,
  });

  Future<CommunityPost> createCertification({
    required int gachaResultId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<CommunityPost> updatePost({
    required int postId,
    required String title,
    required String content,
    required CommunityCategory category,
    String? imageUrl,
  });

  Future<void> deletePost(int postId);

  Future<({bool liked, int likeCount})> toggleLike(int postId);

  Future<List<CommunityComment>> getComments(int postId);

  Future<CommunityComment> createComment(int postId, String content);

  Future<void> deleteComment(int commentId);
}
