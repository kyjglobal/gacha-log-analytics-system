import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacha_log_frontend/app/app.dart';

void main() {
  testWidgets('dashboard renders and opens gacha page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const GachaLogApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome, traveler'), findsOneWidget);
    expect(find.text('Open gacha'), findsOneWidget);

    await tester.tap(find.text('Open gacha'));
    await tester.pumpAndSettle();

    expect(find.text('Celestial Trace'), findsOneWidget);
    expect(find.text('Draw 10'), findsOneWidget);
  });
}
