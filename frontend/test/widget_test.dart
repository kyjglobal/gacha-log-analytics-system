import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacha_log_frontend/app/app.dart';

void main() {
  testWidgets('로그아웃 사용자는 시스템 소개와 로그인 화면을 본다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: GachaLogApp()));
    await tester.pumpAndSettle();

    expect(find.text('아스트라 기록 보관소'), findsOneWidget);
    expect(find.textContaining('가챠 기록을 모으고'), findsOneWidget);
    expect(find.text('가챠 결과 기록'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);

    await tester.tap(find.text('처음이신가요? 새 계정 만들기'));
    await tester.pumpAndSettle();

    expect(find.text('새 계정 만들기'), findsOneWidget);
    expect(find.text('닉네임'), findsOneWidget);
    expect(find.text('회원가입'), findsOneWidget);
  });
}
