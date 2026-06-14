import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _accessTokenKey = 'access_token';
  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _accessTokenKey);

  Future<void> write(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/v1',
    ),
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 15),
           headers: const {'Content-Type': 'application/json'},
         ),
       ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
}
