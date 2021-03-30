import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';

import '../lib/providers/firebase_auth_provider.dart';
import '../lib/views/auth_page.dart';

void main() {
  Widget makeWidgetTestable(Widget child) {
    return MaterialApp(
      home: KeyboardVisibilityProvider(
        child: child,
      ),
    );
  }

  testWidgets('Auth Page: changing forms (Log in -> Sign in)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          AuthPage(
            initialMode: AuthPageMode.login,
          ),
        ),
      ),
    );
    final logInFinder = find.widgetWithText(ElevatedButton, "Log in");
    final signInFinder = find.widgetWithText(ElevatedButton, "Sign in");
    final toSignInButtonFinder =
        find.widgetWithText(TextButton, "I need an account");
    final toLogInButtonFinder =
        find.widgetWithText(TextButton, "I already have an account");
    final emailInputFinder = find.byKey(Key("E-mail_input"));
    final passwordInputFinder = find.byKey(Key("Password_input"));
    final confirmPasswordInputFinder =
        find.byKey(Key("Confirm password_input"));

    // EXPECT LOGIN PAGE
    expect(logInFinder, findsOneWidget);
    expect(signInFinder, findsNothing);
    expect(emailInputFinder, findsOneWidget);
    expect(passwordInputFinder, findsOneWidget);
    expect(confirmPasswordInputFinder,
        findsOneWidget); // Confirm Password input is rendered with CrossFade effect on Sign-in Form expansion
    // so it's there even if it's not visible
    expect(toSignInButtonFinder, findsOneWidget);
    expect(toLogInButtonFinder, findsNothing);

    // Change form to Sign in Form
    await tester.tap(toSignInButtonFinder);
    await tester.pumpAndSettle();

    // EXPECT SIGNIN PAGE
    expect(logInFinder, findsNothing);
    expect(signInFinder, findsOneWidget);
    expect(emailInputFinder, findsOneWidget);
    expect(passwordInputFinder, findsOneWidget);
    expect(confirmPasswordInputFinder, findsOneWidget);
    expect(toSignInButtonFinder, findsNothing);
    expect(toLogInButtonFinder, findsOneWidget);
  });

  testWidgets('Auth Page: changing forms (Sign in -> Log in)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          AuthPage(
            initialMode: AuthPageMode.signin,
          ),
        ),
      ),
    );
    final logInFinder = find.widgetWithText(ElevatedButton, "Log in");
    final signInFinder = find.widgetWithText(ElevatedButton, "Sign in");
    final toSignInButtonFinder =
        find.widgetWithText(TextButton, "I need an account");
    final toLogInButtonFinder =
        find.widgetWithText(TextButton, "I already have an account");
    final emailInputFinder = find.byKey(Key("E-mail_input"));
    final passwordInputFinder = find.byKey(Key("Password_input"));
    final confirmPasswordInputFinder =
        find.byKey(Key("Confirm password_input"));

    // EXPECT SIGNIN PAGE
    expect(logInFinder, findsNothing);
    expect(signInFinder, findsOneWidget);
    expect(emailInputFinder, findsOneWidget);
    expect(passwordInputFinder, findsOneWidget);
    expect(confirmPasswordInputFinder, findsOneWidget);
    expect(toSignInButtonFinder, findsNothing);
    expect(toLogInButtonFinder, findsOneWidget);

    // Change form to Sign in Form
    await tester.tap(toLogInButtonFinder);
    await tester.pumpAndSettle();

    // EXPECT LOGIN PAGE
    expect(logInFinder, findsOneWidget);
    expect(signInFinder, findsNothing);
    expect(emailInputFinder, findsOneWidget);
    expect(passwordInputFinder, findsOneWidget);
    expect(confirmPasswordInputFinder,
        findsOneWidget); // Confirm Password input is rendered with CrossFade effect on Sign-in Form expansion
    // so it's there even if it's not visible
    expect(toSignInButtonFinder, findsOneWidget);
    expect(toLogInButtonFinder, findsNothing);
  });

  group("Auth Page: Fields requirements", () {
    testWidgets('[Not empty]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.signin,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithProvider(
                StateNotifierProvider.autoDispose(
                    (ref) => MockFirebaseAuthNotifier()))
          ],
        ),
      );
      final logInFinder = find.widgetWithText(ElevatedButton, "Log in");
      final signInFinder = find.widgetWithText(ElevatedButton, "Sign in");
      final toSignInButtonFinder =
          find.widgetWithText(TextButton, "I need an account");
      final toLogInButtonFinder =
          find.widgetWithText(TextButton, "I already have an account");
      final emailInputFinder = find.byKey(Key("E-mail_input"));
      final passwordInputFinder = find.byKey(Key("Password_input"));
      final confirmPasswordInputFinder =
          find.byKey(Key("Confirm password_input"));
      final fieldRequiredError = find.text("Field required!");

      // EXPECT SIGNIN PAGE
      expect(logInFinder, findsNothing);
      expect(signInFinder, findsOneWidget);
      expect(emailInputFinder, findsOneWidget);
      expect(passwordInputFinder, findsOneWidget);
      expect(confirmPasswordInputFinder, findsOneWidget);
      expect(toSignInButtonFinder, findsNothing);
      expect(toLogInButtonFinder, findsOneWidget);

      // No errors
      expect(fieldRequiredError, findsNothing);

      // 3 errors
      await tester.tap(signInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNWidgets(3));

      // 2 errors
      await tester.enterText(emailInputFinder, "test@example.com");
      await tester.tap(signInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNWidgets(2));

      // 1 errors
      await tester.enterText(passwordInputFinder, "123123");
      await tester.tap(signInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNWidgets(1));

      // No errors
      await tester.enterText(confirmPasswordInputFinder, "123123");
      await tester.tap(signInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNothing);

      await tester.pump();
    });
  });
}

class MockFirebaseAuthNotifier extends FirebaseAuthNotifier {
  MockFirebaseAuthNotifier() : super(WANDFirebaseConnection());

  @override
  void init() {}

  @override
  Future<void> registerWithEmailAndPasswd(String email, String passwd) async {
    return;
  }
}
