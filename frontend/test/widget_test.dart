import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacha_log_frontend/app/app.dart';

void main() {
  testWidgets('logged-out user opens gacha login prompt', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: GachaLogApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, traveler'), findsOneWidget);
    expect(find.text('Open gacha'), findsOneWidget);

    await tester.tap(find.text('Open gacha'));
    await tester.pumpAndSettle();

    expect(find.text('Celestial Trace'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });
}
