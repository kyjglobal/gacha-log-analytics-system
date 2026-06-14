class ApiClient {
  ApiClient({this.baseUrl = 'http://localhost:8000/api/v1'});

  final String baseUrl;

  Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
