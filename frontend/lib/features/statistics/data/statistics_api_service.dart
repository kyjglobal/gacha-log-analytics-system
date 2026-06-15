import '../../../core/network/api_client.dart';

class StatisticsApiService {
  StatisticsApiService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getMyStatistics({int? bannerId}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/statistics/me',
      queryParameters: {'banner_id': ?bannerId},
    );
    return response.data!;
  }
}
