import '../../../core/network/api_client.dart';

class RankingApiService {
  RankingApiService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getRankings({
    int? bannerId,
    required int minimumDraws,
    required int limit,
  }) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/rankings',
      queryParameters: {
        'banner_id': ?bannerId,
        'minimum_draws': minimumDraws,
        'limit': limit,
      },
    );
    return response.data!;
  }
}
