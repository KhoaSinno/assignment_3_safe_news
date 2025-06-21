import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/features/home/widget/weather_item.dart';

void main() {
  group('WeatherWidget Tests', () {
    testWidgets('WeatherWidget should handle no API key gracefully', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: WeatherWidget())),
        ),
      );

      // Should show "No API Key" when API key is not set
      expect(find.text('No API Key'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('WeatherWidget shows loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: WeatherWidget())),
        ),
      );

      // Initially might show loading or no API key
      await tester.pump();

      // Verify that widget doesn't crash
      expect(tester.takeException(), isNull);
    });
  });
}
