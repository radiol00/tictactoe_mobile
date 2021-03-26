import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/views/auth_page.dart';
import 'package:wand_tictactoe/views/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: KeyboardVisibilityProvider(
        child: Main(),
      ),
    ),
  );
}

class Main extends StatelessWidget {
  Widget _watchLandingPageVisiblity(
      T Function<T>(ProviderBase<Object, T>) watch, BuildContext context) {
    return watch(landingPageVisibilityController.state).when(
      data: (bool landingPageDone) {
        if (landingPageDone)
          return AuthPage(
            initialMode: AuthPageMode.login,
          );
        else
          return LandingPage();
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text("Error"),
        );
      },
    );
  }

  Widget _watchAuthState(
      T Function<T>(ProviderBase<Object, T>) watch, BuildContext context) {
    return watch(firebaseAuthController.state).when(
      data: (TTTUser user) {
        if (user == null) {
          return _watchLandingPageVisiblity(watch, context);
        } else {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read(firebaseAuthController).logout();
              },
              child: Text("logout"),
            ),
          );
        }
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text("Error"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tic-Tac-Toe Mobile',
        theme: ThemeData(
          canvasColor: Colors.white,
          primaryColor: Colors.black,
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all(
                ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
          ),
        ),
        home: Scaffold(
          body: Consumer(
            builder: (context, watch, child) {
              return _watchAuthState(watch, context);
            },
          ),
        ));
  }
}
