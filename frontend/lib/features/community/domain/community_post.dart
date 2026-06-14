import 'community_category.dart';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.authorNickname,
    required this.title,
    required this.content,
    required this.category,
    required this.likeCount,
    required this.viewCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      authorNickname: json['author_nickname'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: CommunityCategory.fromLabel(json['category'] as String),
      imageUrl: json['image_url'] as String?,
      likeCount: json['like_count'] as int,
      viewCount: json['view_count'] as int,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final int userId;
  final String authorNickname;
  final String title;
  final String content;
  final CommunityCategory category;
  final String? imageUrl;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CommunityPostPage {
  const CommunityPostPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.pages,
  });

  factory CommunityPostPage.fromJson(Map<String, dynamic> json) {
    return CommunityPostPage(
      items: (json['items'] as List<dynamic>)
          .map((item) => CommunityPost.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }

  final List<CommunityPost> items;
  final int page;
  final int size;
  final int total;
  final int pages;
}
