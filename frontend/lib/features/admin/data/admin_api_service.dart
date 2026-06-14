import '../../../core/network/api_client.dart';

class AdminApiService {
  AdminApiService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/admin/dashboard',
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getUsers({String? search}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/admin/users',
      queryParameters: {'search': ?search},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> updateUserStatus(
    int userId,
    String status,
  ) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      '/admin/users/$userId/status',
      data: {'status': status},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> adjustInventory({
    required int userId,
    required int itemId,
    required int quantityDelta,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/admin/users/$userId/inventory-adjustments',
      data: {'item_id': itemId, 'quantity_delta': quantityDelta},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getGachaSessions() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/admin/gacha-sessions',
    );
    return response.data!;
  }

  Future<void> deleteGachaSession(int sessionId) {
    return _client.dio.delete<void>('/admin/gacha-sessions/$sessionId');
  }
}
