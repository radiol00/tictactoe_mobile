import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/services/wand_shared_preferences.dart';
import 'package:wand_tictactoe/views/landing_page.dart';

void main() {
  Widget makeWidgetTestable(Widget child) {
    return MaterialApp(
      home: KeyboardVisibilityProvider(
        child: child,
      ),
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
          landingPageVisibilityController.overrideWithValue(
            MockLandingPageVisibilityNotifier(done: false),
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
    await tester.pump(Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(signInFinder, findsOneWidget);
  });
}

class MockLandingPageVisibilityNotifier extends LandingPageVisibilityNotifier {
  MockLandingPageVisibilityNotifier({this.done})
      : super(WANDSharedPreferences());

  bool done;

  @override
  void init() {
    state = AsyncValue.data(done);
    return;
  }

  @override
  void seen() {
    return;
  }
}
