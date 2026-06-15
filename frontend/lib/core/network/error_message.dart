import 'package:dio/dio.dart';

String userErrorMessage(Object? error) {
  if (error is DioException) {
    final detail = _responseDetail(error.response?.data);
    if (detail != null) return detail;

    return switch (error.type) {
      DioExceptionType.connectionError =>
        '서버에 연결할 수 없습니다. 서버 실행 상태와 네트워크를 확인하세요.',
      DioExceptionType.connectionTimeout => '서버 연결 시간이 초과되었습니다. 잠시 후 다시 시도하세요.',
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '서버 응답 시간이 초과되었습니다. 잠시 후 다시 시도하세요.',
      DioExceptionType.badCertificate => '서버 인증서를 확인할 수 없습니다.',
      DioExceptionType.cancel => '요청이 취소되었습니다.',
      DioExceptionType.badResponse => _statusMessage(
        error.response?.statusCode,
      ),
      DioExceptionType.unknown => '네트워크 요청 중 오류가 발생했습니다.',
    };
  }
  if (error is StateError) {
    return error.message.toString();
  }
  return '요청을 처리하지 못했습니다. 잠시 후 다시 시도하세요.';
}

String? _responseDetail(Object? data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is String && detail.trim().isNotEmpty) return detail;
  if (detail is List && detail.isNotEmpty) {
    return '입력한 내용을 확인해 주세요.';
  }
  return null;
}

String _statusMessage(int? statusCode) {
  return switch (statusCode) {
    400 => '잘못된 요청입니다. 입력한 내용을 확인해 주세요.',
    401 => '로그인이 필요하거나 인증 정보가 올바르지 않습니다.',
    403 => '이 작업을 수행할 권한이 없습니다.',
    404 => '요청한 정보를 찾을 수 없습니다.',
    409 => '이미 존재하거나 현재 상태에서는 처리할 수 없는 정보입니다.',
    422 => '입력한 내용을 확인해 주세요.',
    500 => '서버 내부 오류가 발생했습니다. 잠시 후 다시 시도하세요.',
    _ => '서버 요청을 처리하지 못했습니다. 잠시 후 다시 시도하세요.',
  };
}
