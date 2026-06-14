import 'admin_models.dart';

abstract interface class AdminRepository {
  Future<AdminDashboard> getDashboard();

  Future<AdminUserPage> getUsers({String? search});

  Future<AdminUser> updateUserStatus(int userId, String status);

  Future<void> adjustInventory({
    required int userId,
    required int itemId,
    required int quantityDelta,
  });

  Future<AdminGachaSessionPage> getGachaSessions();

  Future<void> deleteGachaSession(int sessionId);
}
