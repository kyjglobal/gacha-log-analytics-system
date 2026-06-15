import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../data/auth_api_service.dart';
import '../domain/auth_session.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(apiClientProvider));
});

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthSession?>(
      AuthSessionNotifier.new,
    );

class AuthSessionNotifier extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null) return null;
    try {
      final user = await ref.read(authApiServiceProvider).getMe();
      return AuthSession(accessToken: token, user: user);
    } catch (_) {
      await ref.read(tokenStorageProvider).clear();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authApiServiceProvider)
          .login(email: email, password: password);
      await ref.read(tokenStorageProvider).write(session.accessToken);
      return session;
    });
  }

  Future<void> signUp({
    required String email,
    required String nickname,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authApiServiceProvider)
          .signUp(email: email, nickname: nickname, password: password);
      await ref.read(tokenStorageProvider).write(session.accessToken);
      return session;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }

  Future<AuthUser> updateNickname(String nickname) async {
    final current = state.value;
    if (current == null) {
      throw StateError('로그인이 필요합니다.');
    }
    final user = await ref
        .read(authApiServiceProvider)
        .updateAccount(nickname: nickname);
    state = AsyncData(
      AuthSession(accessToken: current.accessToken, user: user),
    );
    return user;
  }

  Future<void> deleteAccount(String password) async {
    await ref.read(authApiServiceProvider).deleteAccount(password: password);
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}
