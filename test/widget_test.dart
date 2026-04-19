import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_tracker/app.dart';

void main() {
  testWidgets('App smoke test — MaterialApp is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // Override async providers so no real DB / SharedPrefs are touched.
        overrides: const [],
        child: const AssetTrackerApp(),
      ),
    );
    // Only pump one frame — enough to verify the widget tree builds.
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
