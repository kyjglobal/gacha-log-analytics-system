import '../../../core/network/api_client.dart';
import '../domain/community_category.dart';

class CommunityApiService {
  CommunityApiService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getPosts({
    required int page,
    required int size,
    CommunityCategory? category,
    String? search,
  }) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/community/posts',
      queryParameters: {
        'page': page,
        'size': size,
        if (category != null) 'category': category.label,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getPost(int postId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/community/posts/$postId',
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/community/posts',
      data: data,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> createCertification(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/community/certifications',
      data: data,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> updatePost(
    int postId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.dio.put<Map<String, dynamic>>(
      '/community/posts/$postId',
      data: data,
    );
    return response.data!;
  }

  Future<void> deletePost(int postId) {
    return _client.dio.delete<void>('/community/posts/$postId');
  }

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/community/posts/$postId/like',
    );
    return response.data!;
  }

  Future<List<dynamic>> getComments(int postId) async {
    final response = await _client.dio.get<List<dynamic>>(
      '/community/posts/$postId/comments',
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> createComment(int postId, String content) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/community/posts/$postId/comments',
      data: {'content': content},
    );
    return response.data!;
  }

  Future<void> deleteComment(int commentId) {
    return _client.dio.delete<void>('/community/comments/$commentId');
  }
}
