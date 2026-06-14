import '../domain/admin_models.dart';
import '../domain/admin_repository.dart';
import 'admin_api_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._api);

  final AdminApiService _api;

  @override
  Future<AdminDashboard> getDashboard() async {
    return AdminDashboard.fromJson(await _api.getDashboard());
  }

  @override
  Future<AdminUserPage> getUsers({String? search}) async {
    return AdminUserPage.fromJson(await _api.getUsers(search: search));
  }

  @override
  Future<AdminUser> updateUserStatus(int userId, String status) async {
    return AdminUser.fromJson(await _api.updateUserStatus(userId, status));
  }

  @override
  Future<void> adjustInventory({
    required int userId,
    required int itemId,
    required int quantityDelta,
  }) async {
    await _api.adjustInventory(
      userId: userId,
      itemId: itemId,
      quantityDelta: quantityDelta,
    );
  }

  @override
  Future<AdminGachaSessionPage> getGachaSessions() async {
    return AdminGachaSessionPage.fromJson(await _api.getGachaSessions());
  }

  @override
  Future<void> deleteGachaSession(int sessionId) {
    return _api.deleteGachaSession(sessionId);
  }
}
