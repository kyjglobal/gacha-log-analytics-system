import '../domain/gacha_models.dart';
import '../domain/gacha_repository.dart';
import 'gacha_api_service.dart';

class GachaRepositoryImpl implements GachaRepository {
  GachaRepositoryImpl(this._api);

  final GachaApiService _api;

  @override
  Future<List<GachaBanner>> getBanners() async {
    final json = await _api.getBanners();
    return json
        .map((item) => GachaBanner.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GachaDraw> draw({
    required int bannerId,
    required int count,
    required String idempotencyKey,
  }) async {
    return GachaDraw.fromJson(
      await _api.draw(
        bannerId: bannerId,
        count: count,
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  @override
  Future<GachaHistoryPage> getHistory({int page = 1, int size = 20}) async {
    return GachaHistoryPage.fromJson(
      await _api.getHistory(page: page, size: size),
    );
  }

  @override
  Future<List<InventoryEntry>> getInventory({String? rarity}) async {
    final json = await _api.getInventory(rarity: rarity);
    return (json['items'] as List<dynamic>)
        .map((item) => InventoryEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
