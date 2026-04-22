import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arsenal_manager/main.dart';
import 'package:arsenal_manager/providers/arsenal_provider.dart';
import 'fakes/fake_api_service.dart';

void main() {
  testWidgets('App renders bottom nav bar with four tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(FakeApiService()),
        ],
        child: const ArsenalManagerApp(),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Arsenal'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
  });
}
