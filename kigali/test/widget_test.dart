// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kigali/main.dart';
import 'package:kigali/providers/listings_provider.dart';
import 'package:kigali/providers/settings_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // MyApp requires pre-built providers since Firebase init happens in main().
    // This test just verifies the widget tree constructs without crashing.
    final settings = SettingsProvider();
    final listings = ListingsProvider();
    await tester.pumpWidget(
      MyApp(settingsProvider: settings, listingsProvider: listings),
    );
    // Basic sanity: app renders at least one widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
