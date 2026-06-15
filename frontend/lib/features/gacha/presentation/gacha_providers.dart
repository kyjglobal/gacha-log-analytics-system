import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../data/gacha_api_service.dart';
import '../data/gacha_repository_impl.dart';
import '../domain/gacha_models.dart';
import '../domain/gacha_repository.dart';

final gachaApiServiceProvider = Provider<GachaApiService>((ref) {
  return GachaApiService(ref.watch(apiClientProvider));
});

final gachaRepositoryProvider = Provider<GachaRepository>((ref) {
  return GachaRepositoryImpl(ref.watch(gachaApiServiceProvider));
});

final gachaBannersProvider = FutureProvider<List<GachaBanner>>((ref) {
  return ref.watch(gachaRepositoryProvider).getBanners();
});

final gachaHistoryProvider = FutureProvider<GachaHistoryPage>((ref) {
  return ref.watch(gachaRepositoryProvider).getHistory();
});

final inventoryProvider = FutureProvider.family<List<InventoryEntry>, String?>((
  ref,
  rarity,
) {
  return ref.watch(gachaRepositoryProvider).getInventory(rarity: rarity);
});

final gachaDrawProvider = AsyncNotifierProvider<GachaDrawNotifier, GachaDraw?>(
  GachaDrawNotifier.new,
);

class GachaDrawNotifier extends AsyncNotifier<GachaDraw?> {
  @override
  Future<GachaDraw?> build() async => null;

  Future<GachaDraw?> draw({required int bannerId, required int count}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(gachaRepositoryProvider)
          .draw(
            bannerId: bannerId,
            count: count,
            idempotencyKey:
                'flutter-${DateTime.now().microsecondsSinceEpoch}-$count',
          ),
    );
    if (state.hasValue) {
      ref.invalidate(gachaBannersProvider);
      ref.invalidate(gachaHistoryProvider);
      ref.invalidate(inventoryProvider);
    }
    return state.value;
  }
}
