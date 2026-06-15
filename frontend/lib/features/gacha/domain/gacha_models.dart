class GachaPoolItem {
  const GachaPoolItem({
    required this.itemId,
    required this.itemName,
    required this.rarity,
    required this.officialProbability,
  });

  factory GachaPoolItem.fromJson(Map<String, dynamic> json) {
    return GachaPoolItem(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      rarity: json['rarity'] as String,
      officialProbability: (json['official_probability'] as num).toDouble(),
    );
  }

  final int itemId;
  final String itemName;
  final String rarity;
  final double officialProbability;
}

class GachaBanner {
  const GachaBanner({
    required this.id,
    required this.name,
    required this.costPerDraw,
    required this.pityThreshold,
    required this.pityCount,
    required this.walletBalance,
    required this.pool,
  });

  factory GachaBanner.fromJson(Map<String, dynamic> json) {
    return GachaBanner(
      id: json['id'] as int,
      name: json['name'] as String,
      costPerDraw: json['cost_per_draw'] as int,
      pityThreshold: json['pity_threshold'] as int,
      pityCount: json['pity_count'] as int,
      walletBalance: json['wallet_balance'] as int,
      pool: (json['pool'] as List<dynamic>)
          .map((item) => GachaPoolItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;
  final int costPerDraw;
  final int pityThreshold;
  final int pityCount;
  final int walletBalance;
  final List<GachaPoolItem> pool;
}

class GachaResultItem {
  const GachaResultItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.rarity,
    required this.sequence,
    required this.officialProbability,
    required this.appliedProbability,
    required this.wasPityApplied,
  });

  factory GachaResultItem.fromJson(Map<String, dynamic> json) {
    return GachaResultItem(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      rarity: json['rarity'] as String,
      sequence: json['sequence'] as int,
      officialProbability: (json['official_probability'] as num).toDouble(),
      appliedProbability: (json['applied_probability'] as num).toDouble(),
      wasPityApplied: json['was_pity_applied'] as bool,
    );
  }

  final int id;
  final int itemId;
  final String itemName;
  final String rarity;
  final int sequence;
  final double officialProbability;
  final double appliedProbability;
  final bool wasPityApplied;
}

class GachaDraw {
  const GachaDraw({
    required this.sessionId,
    required this.bannerId,
    required this.bannerName,
    required this.drawCount,
    required this.totalCost,
    required this.pityBefore,
    required this.pityAfter,
    required this.balanceAfter,
    required this.createdAt,
    required this.results,
  });

  factory GachaDraw.fromJson(Map<String, dynamic> json) {
    return GachaDraw(
      sessionId: json['session_id'] as int,
      bannerId: json['banner_id'] as int,
      bannerName: json['banner_name'] as String,
      drawCount: json['draw_count'] as int,
      totalCost: json['total_cost'] as int,
      pityBefore: json['pity_before'] as int,
      pityAfter: json['pity_after'] as int,
      balanceAfter: json['balance_after'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      results: (json['results'] as List<dynamic>)
          .map((item) => GachaResultItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int sessionId;
  final int bannerId;
  final String bannerName;
  final int drawCount;
  final int totalCost;
  final int pityBefore;
  final int pityAfter;
  final int balanceAfter;
  final DateTime createdAt;
  final List<GachaResultItem> results;
}

class GachaHistoryPage {
  const GachaHistoryPage({
    required this.items,
    required this.total,
    required this.pages,
  });

  factory GachaHistoryPage.fromJson(Map<String, dynamic> json) {
    return GachaHistoryPage(
      items: (json['items'] as List<dynamic>)
          .map((item) => GachaDraw.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }

  final List<GachaDraw> items;
  final int total;
  final int pages;
}

class InventoryEntry {
  const InventoryEntry({
    required this.itemId,
    required this.itemName,
    required this.rarity,
    required this.quantity,
    required this.updatedAt,
    this.imageUrl,
  });

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
    return InventoryEntry(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      rarity: json['rarity'] as String,
      imageUrl: json['image_url'] as String?,
      quantity: json['quantity'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int itemId;
  final String itemName;
  final String rarity;
  final String? imageUrl;
  final int quantity;
  final DateTime updatedAt;
}
