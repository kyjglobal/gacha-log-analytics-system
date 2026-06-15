import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacha_log_frontend/core/network/error_message.dart';

void main() {
  test('서버 상세 오류 메시지를 표시한다', () {
    final request = RequestOptions(path: '/auth/login');
    final error = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 401,
        data: {'detail': '이메일 또는 비밀번호가 올바르지 않습니다.'},
      ),
      type: DioExceptionType.badResponse,
    );

    expect(userErrorMessage(error), '이메일 또는 비밀번호가 올바르지 않습니다.');
  });

  test('네트워크 연결 오류를 한국어로 안내한다', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/health'),
      type: DioExceptionType.connectionError,
    );

    expect(userErrorMessage(error), '서버에 연결할 수 없습니다. 서버 실행 상태와 네트워크를 확인하세요.');
  });

  test('입력값 검증 오류를 일반 사용자 문구로 안내한다', () {
    final request = RequestOptions(path: '/community/posts');
    final error = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 422,
        data: {
          'detail': [
            {'msg': 'Field required'},
          ],
        },
      ),
      type: DioExceptionType.badResponse,
    );

    expect(userErrorMessage(error), '입력한 내용을 확인해 주세요.');
  });
}
