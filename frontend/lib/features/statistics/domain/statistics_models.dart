class RarityStatistic {
  const RarityStatistic({
    required this.rarity,
    required this.officialProbability,
    required this.personalCount,
    required this.personalProbability,
    required this.personalDeviation,
    required this.communityCount,
    required this.communityProbability,
  });

  factory RarityStatistic.fromJson(Map<String, dynamic> json) {
    return RarityStatistic(
      rarity: json['rarity'] as String,
      officialProbability: (json['official_probability'] as num).toDouble(),
      personalCount: json['personal_count'] as int,
      personalProbability: (json['personal_probability'] as num).toDouble(),
      personalDeviation: (json['personal_deviation'] as num).toDouble(),
      communityCount: json['community_count'] as int,
      communityProbability: (json['community_probability'] as num).toDouble(),
    );
  }

  final String rarity;
  final double officialProbability;
  final int personalCount;
  final double personalProbability;
  final double personalDeviation;
  final int communityCount;
  final double communityProbability;
}

class ProbabilityStatistics {
  const ProbabilityStatistics({
    required this.bannerId,
    required this.bannerName,
    required this.personalTotalDraws,
    required this.communityTotalDraws,
    required this.luckScore,
    required this.rarities,
  });

  factory ProbabilityStatistics.fromJson(Map<String, dynamic> json) {
    return ProbabilityStatistics(
      bannerId: json['banner_id'] as int,
      bannerName: json['banner_name'] as String,
      personalTotalDraws: json['personal_total_draws'] as int,
      communityTotalDraws: json['community_total_draws'] as int,
      luckScore: (json['luck_score'] as num).toDouble(),
      rarities: (json['rarities'] as List<dynamic>)
          .map((item) => RarityStatistic.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int bannerId;
  final String bannerName;
  final int personalTotalDraws;
  final int communityTotalDraws;
  final double luckScore;
  final List<RarityStatistic> rarities;
}
