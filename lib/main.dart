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
            builder: (context, watch, _) {
              return watch(firebaseAuthController.state).when(
                data: (TTTUser user) {
                  if (user == null) {
                    return watch(landingPageVisibilityController.state).when(
                      data: (bool landingPageDone) {
                        if (landingPageDone)
                          return AuthPage();
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
                  } else {
                    context.read(firebaseAuthController).logout();
                    return Center(
                      child: Text("USER!!!"),
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
            },
          ),
        ));
  }
}
