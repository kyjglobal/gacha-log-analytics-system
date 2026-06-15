import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class GachaApiService {
  GachaApiService(this._client);

  final ApiClient _client;

  Future<List<dynamic>> getBanners() async {
    final response = await _client.dio.get<List<dynamic>>('/gacha/banners');
    return response.data!;
  }

  Future<Map<String, dynamic>> draw({
    required int bannerId,
    required int count,
    required String idempotencyKey,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/gacha/draw',
      data: {'banner_id': bannerId, 'count': count},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getHistory({
    required int page,
    required int size,
  }) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/gacha/history',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getInventory({String? rarity}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/inventory',
      queryParameters: {'rarity': ?rarity},
    );
    return response.data!;
  }
}
