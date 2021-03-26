import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/services/wand_shared_preferences.dart';
import 'package:wand_tictactoe/views/landing_page.dart';

void main() {
  Widget makeWidgetTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets(
      'Landing Page: go through all pages and proceed to authorization page',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          LandingPage(),
        ),
        overrides: [
          landingPageVisibilityController.overrideWithProvider(
            StateNotifierProvider.autoDispose(
              (ref) => MockLandingPageVisibilityNotifier(),
            ),
          ),
        ],
      ),
    );
    final nextFinder = find.widgetWithText(TextButton, "Next");
    final createFinder = find.widgetWithText(TextButton, "Create an account");
    final signInFinder = find.widgetWithText(ElevatedButton, "Sign in");

    expect(nextFinder, findsOneWidget);
    await tester.tap(nextFinder);
    await tester.pumpAndSettle();

    expect(nextFinder, findsOneWidget);
    await tester.tap(nextFinder);
    await tester.pumpAndSettle();

    expect(nextFinder, findsOneWidget);
    await tester.tap(nextFinder);
    await tester.pumpAndSettle();

    expect(createFinder, findsOneWidget);
    await tester.tap(createFinder);
    await tester.pumpAndSettle();

    expect(signInFinder, findsOneWidget);
  });
}

class MockLandingPageVisibilityNotifier extends LandingPageVisibilityNotifier {
  MockLandingPageVisibilityNotifier() : super(WANDSharedPreferences());

  @override
  void init() {
    state = AsyncValue.data(false);
    return;
  }

  @override
  void seen() {
    return;
  }
}
