import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wand_tictactoe/main.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/views/auth_page.dart';

import 'landing_page_test.dart';

void main() {
  Widget makeWidgetTestable(Widget child) {
    return MaterialApp(
      home: KeyboardVisibilityProvider(
        child: child,
      ),
    );
  }

  final logInFinder = find.widgetWithText(ElevatedButton, "Log in");
  final signInFinder = find.widgetWithText(ElevatedButton, "Sign in");
  final toSignInButtonFinder =
      find.widgetWithText(TextButton, "I need an account");
  final toLogInButtonFinder =
      find.widgetWithText(TextButton, "I already have an account");
  final emailInputFinder = find.byKey(Key("E-mail_input"));
  final passwordInputFinder = find.byKey(Key("Password_input"));
  final confirmPasswordInputFinder = find.byKey(Key("Confirm password_input"));
  final wrongEmailFormatError = find.text("Wrong email format!");
  final fieldRequiredError = find.text("Field required!");
  final passwdLengthRequiredError =
      find.text("Should be at least 6 characters long!");
  final passwdConfirmRequiredError = find.text("Passwords don't match!");
  final mainMenuPageFinder = find.byKey(Key("MainMenuPageKey"));
  final snackBarFinder = find.byKey(Key("SnackBarKey"));

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
    testWidgets('Sign in: [Not empty]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.signin,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithValue(
              MockFirebaseAuthNotifier(
                MockFirebaseAuthNotifierMode.noInteraction,
              ),
            ),
          ],
        ),
      );

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

      // 1 error
      await tester.enterText(passwordInputFinder, "123123");
      await tester.tap(signInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNWidgets(1));

      // No errors
      await tester.enterText(confirmPasswordInputFinder, "123123");
      await tester.tap(signInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNothing);
    });

    testWidgets('Sign in: [Password length]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.signin,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithValue(
              MockFirebaseAuthNotifier(
                MockFirebaseAuthNotifierMode.noInteraction,
              ),
            ),
          ],
        ),
      );

      // EXPECT SIGNIN PAGE
      expect(logInFinder, findsNothing);
      expect(signInFinder, findsOneWidget);
      expect(emailInputFinder, findsOneWidget);
      expect(passwordInputFinder, findsOneWidget);
      expect(confirmPasswordInputFinder, findsOneWidget);
      expect(toSignInButtonFinder, findsNothing);
      expect(toLogInButtonFinder, findsOneWidget);

      // No errors
      expect(passwdLengthRequiredError, findsNothing);

      await tester.enterText(passwordInputFinder, "12345");
      await tester.tap(signInFinder);
      await tester.pump();

      expect(passwdLengthRequiredError, findsOneWidget);

      await tester.enterText(passwordInputFinder, "123456");
      await tester.tap(signInFinder);
      await tester.pump();

      expect(passwdLengthRequiredError, findsNothing);
    });

    testWidgets('Sign in: [Password confirming]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.signin,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithValue(
              MockFirebaseAuthNotifier(
                MockFirebaseAuthNotifierMode.noInteraction,
              ),
            ),
          ],
        ),
      );

      // EXPECT SIGNIN PAGE
      expect(logInFinder, findsNothing);
      expect(signInFinder, findsOneWidget);
      expect(emailInputFinder, findsOneWidget);
      expect(passwordInputFinder, findsOneWidget);
      expect(confirmPasswordInputFinder, findsOneWidget);
      expect(toSignInButtonFinder, findsNothing);
      expect(toLogInButtonFinder, findsOneWidget);

      // No errors
      expect(passwdConfirmRequiredError, findsNothing);

      await tester.enterText(passwordInputFinder, "12345");
      await tester.enterText(confirmPasswordInputFinder, "123");
      await tester.tap(signInFinder);
      await tester.pump();

      expect(passwdConfirmRequiredError, findsOneWidget);

      await tester.enterText(confirmPasswordInputFinder, "12345");
      await tester.tap(signInFinder);
      await tester.pump();

      expect(passwdConfirmRequiredError, findsNothing);
    });

    testWidgets('Sign in: [Email format]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.signin,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithValue(
              MockFirebaseAuthNotifier(
                MockFirebaseAuthNotifierMode.noInteraction,
              ),
            ),
          ],
        ),
      );

      // EXPECT SIGNIN PAGE
      expect(logInFinder, findsNothing);
      expect(signInFinder, findsOneWidget);
      expect(emailInputFinder, findsOneWidget);
      expect(passwordInputFinder, findsOneWidget);
      expect(confirmPasswordInputFinder, findsOneWidget);
      expect(toSignInButtonFinder, findsNothing);
      expect(toLogInButtonFinder, findsOneWidget);

      // No errors
      expect(wrongEmailFormatError, findsNothing);

      await tester.enterText(emailInputFinder, "12345");
      await tester.tap(signInFinder);
      await tester.pump();

      expect(wrongEmailFormatError, findsOneWidget);

      await tester.enterText(emailInputFinder, "123@123.com");
      await tester.tap(signInFinder);
      await tester.pump();

      expect(wrongEmailFormatError, findsNothing);
    });

    testWidgets('Log in: [Not empty]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.login,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithValue(
              MockFirebaseAuthNotifier(
                MockFirebaseAuthNotifierMode.noInteraction,
              ),
            ),
          ],
        ),
      );

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

      // No errors
      expect(fieldRequiredError, findsNothing);

      // 2 errors
      await tester.tap(logInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNWidgets(2));

      // 1 error
      await tester.enterText(emailInputFinder, "test@example.com");
      await tester.tap(logInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNWidgets(1));

      // No errors
      await tester.enterText(passwordInputFinder, "123123");
      await tester.tap(logInFinder);
      await tester.pump();
      expect(fieldRequiredError, findsNothing);
    });

    testWidgets('Log in: [Email format]', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: makeWidgetTestable(
            AuthPage(
              initialMode: AuthPageMode.login,
            ),
          ),
          overrides: [
            firebaseAuthController.overrideWithValue(
              MockFirebaseAuthNotifier(
                MockFirebaseAuthNotifierMode.noInteraction,
              ),
            ),
          ],
        ),
      );

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

      // No errors
      expect(wrongEmailFormatError, findsNothing);

      await tester.enterText(emailInputFinder, "12345");
      await tester.tap(logInFinder);
      await tester.pump();

      expect(wrongEmailFormatError, findsOneWidget);

      await tester.enterText(emailInputFinder, "123@123.com");
      await tester.tap(logInFinder);
      await tester.pump();

      expect(wrongEmailFormatError, findsNothing);
    });
  });

  testWidgets("AuthPage Successful Login", (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          Main(),
        ),
        overrides: [
          firebaseAuthController.overrideWithValue(
            MockFirebaseAuthNotifier(
              MockFirebaseAuthNotifierMode.successfulInteraction,
            ),
          ),
          landingPageVisibilityController.overrideWithValue(
            MockLandingPageVisibilityNotifier(done: true),
          ),
        ],
      ),
    );

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

    await tester.enterText(emailInputFinder, "test@example.com");
    await tester.enterText(passwordInputFinder, "testtest");

    await tester.tap(logInFinder);

    await tester.pumpAndSettle();

    expect(mainMenuPageFinder, findsOneWidget);
    expect(snackBarFinder, findsNothing);
  });

  testWidgets("AuthPage Failed Login", (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          Main(),
        ),
        overrides: [
          firebaseAuthController.overrideWithValue(
            MockFirebaseAuthNotifier(
              MockFirebaseAuthNotifierMode.failedInteraction,
            ),
          ),
          landingPageVisibilityController.overrideWithValue(
            MockLandingPageVisibilityNotifier(done: true),
          ),
        ],
      ),
    );

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

    await tester.enterText(emailInputFinder, "test@example.com");
    await tester.enterText(passwordInputFinder, "testtest");

    await tester.tap(logInFinder);
    await tester.pump();

    expect(mainMenuPageFinder, findsNothing);
    expect(snackBarFinder, findsOneWidget);
  });

  testWidgets("AuthPage Successful Sign in", (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          Main(),
        ),
        overrides: [
          firebaseAuthController.overrideWithValue(
            MockFirebaseAuthNotifier(
              MockFirebaseAuthNotifierMode.successfulInteraction,
            ),
          ),
          landingPageVisibilityController.overrideWithValue(
            MockLandingPageVisibilityNotifier(done: true),
          ),
        ],
      ),
    );

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

    await tester.enterText(emailInputFinder, "test@example.com");
    await tester.enterText(passwordInputFinder, "testtest");
    await tester.enterText(confirmPasswordInputFinder, "testtest");

    await tester.tap(signInFinder);

    await tester.pumpAndSettle();

    expect(mainMenuPageFinder, findsOneWidget);
    expect(snackBarFinder, findsNothing);
  });

  testWidgets("AuthPage Failed Sign in", (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: makeWidgetTestable(
          Main(),
        ),
        overrides: [
          firebaseAuthController.overrideWithValue(
            MockFirebaseAuthNotifier(
              MockFirebaseAuthNotifierMode.failedInteraction,
            ),
          ),
          landingPageVisibilityController.overrideWithValue(
            MockLandingPageVisibilityNotifier(done: true),
          ),
        ],
      ),
    );

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

    await tester.enterText(emailInputFinder, "test@example.com");
    await tester.enterText(passwordInputFinder, "testtest");
    await tester.enterText(confirmPasswordInputFinder, "testtest");

    await tester.tap(signInFinder);
    await tester.pump();

    expect(mainMenuPageFinder, findsNothing);
    expect(snackBarFinder, findsOneWidget);
  });
}

enum MockFirebaseAuthNotifierMode {
  noInteraction,
  successfulInteraction,
  failedInteraction
}

class MockFirebaseAuthNotifier extends FirebaseAuthNotifier {
  MockFirebaseAuthNotifier(MockFirebaseAuthNotifierMode mode) : super(null) {
    _mode = mode;
  }

  MockFirebaseAuthNotifierMode _mode;

  @override
  void init() async {
    state = AsyncValue.data(null);
  }

  @override
  Future<void> registerWithEmailAndPasswd(String email, String passwd) async {
    switch (_mode) {
      case MockFirebaseAuthNotifierMode.noInteraction:
        return;
      case MockFirebaseAuthNotifierMode.successfulInteraction:
        state = AsyncValue.data(TTTUser());
        return;
      case MockFirebaseAuthNotifierMode.failedInteraction:
        throw new FirebaseAuthException(code: "test", message: "test message");
        return;
    }
  }

  @override
  Future<void> loginWithEmailAndPasswd(String email, String passwd) async {
    switch (_mode) {
      case MockFirebaseAuthNotifierMode.noInteraction:
        return;
      case MockFirebaseAuthNotifierMode.successfulInteraction:
        state = AsyncValue.data(TTTUser());
        return;
      case MockFirebaseAuthNotifierMode.failedInteraction:
        throw new FirebaseAuthException(code: "test", message: "test message");
        return;
    }
  }
}
