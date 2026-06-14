import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

class AuthApiService {
  AuthApiService(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<AuthSession> signUp({
    required String email,
    required String nickname,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {'email': email, 'nickname': nickname, 'password': password},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<AuthUser> getMe() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!);
  }
}
