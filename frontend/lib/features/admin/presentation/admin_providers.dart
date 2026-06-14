import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../data/admin_api_service.dart';
import '../data/admin_repository_impl.dart';
import '../domain/admin_models.dart';
import '../domain/admin_repository.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService(ref.watch(apiClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(adminApiServiceProvider));
});

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboard>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).getDashboard();
});

final adminUsersProvider = FutureProvider.autoDispose
    .family<AdminUserPage, String?>((ref, search) {
      return ref.watch(adminRepositoryProvider).getUsers(search: search);
    });

final adminGachaSessionsProvider =
    FutureProvider.autoDispose<AdminGachaSessionPage>((ref) {
      return ref.watch(adminRepositoryProvider).getGachaSessions();
    });
