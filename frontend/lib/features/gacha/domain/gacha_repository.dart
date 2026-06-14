import 'gacha_models.dart';

abstract interface class GachaRepository {
  Future<List<GachaBanner>> getBanners();

  Future<GachaDraw> draw({
    required int bannerId,
    required int count,
    required String idempotencyKey,
  });

  Future<GachaHistoryPage> getHistory({int page = 1, int size = 20});

  Future<List<InventoryEntry>> getInventory({String? rarity});
}
