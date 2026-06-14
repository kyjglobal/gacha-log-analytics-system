class RankingEntry {
  const RankingEntry({
    required this.rank,
    required this.userId,
    required this.nickname,
    required this.totalDraws,
    required this.mythicCount,
    required this.mythicProbability,
    required this.luckScore,
    required this.isCurrentUser,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      nickname: json['nickname'] as String,
      totalDraws: json['total_draws'] as int,
      mythicCount: json['mythic_count'] as int,
      mythicProbability: (json['mythic_probability'] as num).toDouble(),
      luckScore: (json['luck_score'] as num).toDouble(),
      isCurrentUser: json['is_current_user'] as bool,
    );
  }

  final int rank;
  final int userId;
  final String nickname;
  final int totalDraws;
  final int mythicCount;
  final double mythicProbability;
  final double luckScore;
  final bool isCurrentUser;
}

class RankingBoard {
  const RankingBoard({
    required this.bannerId,
    required this.bannerName,
    required this.minimumDraws,
    required this.entries,
    required this.myRank,
  });

  factory RankingBoard.fromJson(Map<String, dynamic> json) {
    return RankingBoard(
      bannerId: json['banner_id'] as int,
      bannerName: json['banner_name'] as String,
      minimumDraws: json['minimum_draws'] as int,
      entries: (json['entries'] as List<dynamic>)
          .map((item) => RankingEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      myRank: json['my_rank'] as int?,
    );
  }

  final int bannerId;
  final String bannerName;
  final int minimumDraws;
  final List<RankingEntry> entries;
  final int? myRank;
}
