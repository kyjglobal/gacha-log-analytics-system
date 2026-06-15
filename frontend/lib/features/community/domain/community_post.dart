import 'community_category.dart';

class ProbabilityCertification {
  const ProbabilityCertification({
    required this.id,
    required this.gachaResultId,
    required this.gachaSessionId,
    required this.itemId,
    required this.itemName,
    required this.itemRarity,
    required this.drawCount,
    required this.officialProbability,
    required this.personalProbability,
    required this.obtainedAt,
  });

  factory ProbabilityCertification.fromJson(Map<String, dynamic> json) {
    return ProbabilityCertification(
      id: json['id'] as int,
      gachaResultId: json['gacha_result_id'] as int,
      gachaSessionId: json['gacha_session_id'] as int,
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      itemRarity: json['item_rarity'] as String,
      drawCount: json['draw_count'] as int,
      officialProbability: (json['official_probability'] as num).toDouble(),
      personalProbability: (json['personal_probability'] as num).toDouble(),
      obtainedAt: DateTime.parse(json['obtained_at'] as String),
    );
  }

  final int id;
  final int gachaResultId;
  final int gachaSessionId;
  final int itemId;
  final String itemName;
  final String itemRarity;
  final int drawCount;
  final double officialProbability;
  final double personalProbability;
  final DateTime obtainedAt;
}

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
    this.certification,
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
      certification: json['certification'] == null
          ? null
          : ProbabilityCertification.fromJson(
              json['certification'] as Map<String, dynamic>,
            ),
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
  final ProbabilityCertification? certification;
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
