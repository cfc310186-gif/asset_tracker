import 'package:asset_tracker/presentation/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows unconfigured message without reading Supabase client', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Cloud login'), findsOneWidget);
    expect(
        find.textContaining('Cloud login is not configured'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });
}
