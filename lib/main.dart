import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';
import 'package:wand_tictactoe/providers/game_controller_provider.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/views/auth_page.dart';
import 'package:wand_tictactoe/views/landing_page.dart';
import 'package:wand_tictactoe/views/main_menu_page.dart';
import 'package:wand_tictactoe/widgets/wand_progress_indicator.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;

void main() async {
  // timeDilation = 10.0;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // bool useDevicePreview = true;
  // if (useDevicePreview) {
  //   runApp(
  //     DevicePreview(
  //       builder: (context) {
  //         return ProviderScope(
  //           child: KeyboardVisibilityProvider(
  //             child: Main(),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // } else {
  runApp(
    ProviderScope(
      child: KeyboardVisibilityProvider(
        child: Main(),
      ),
    ),
  );
  // }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  bool wasAlreadyLoggedIn = true;
  bool shouldUseAnimatedSwitcher = false;

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
          child: WANDProgressIndicator(
            type: WANDProgressIndicatorType.fullscreen,
            size: 100,
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text("Error"),
        );
      },
    );
  }

  Widget _watchGameInstance(
      T Function<T>(ProviderBase<Object, T>) watch, BuildContext context) {
    return watch(gameController.state).when(
      data: (data) {
        if (data == null) {
          return MainMenuPage(
            key: Key("MainMenuPageKey"),
            delayInitAnimations: !wasAlreadyLoggedIn,
          );
        }
        return Center(
          child: Text("NOMC GIERKA"),
        );
      },
      loading: () {
        return Center(
          child: WANDProgressIndicator(
            type: WANDProgressIndicatorType.fullscreen,
            size: 100,
          ),
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
        shouldUseAnimatedSwitcher = true;
        if (user == null) {
          wasAlreadyLoggedIn = false;
          return _watchLandingPageVisiblity(watch, context);
        } else {
          return _watchGameInstance(watch, context);
        }
      },
      loading: () {
        return Center(
          child: WANDProgressIndicator(
            type: WANDProgressIndicatorType.fullscreen,
            size: 100,
          ),
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
        // builder: DevicePreview.appBuilder,
        title: 'Tic-Tac-Toe Mobile',
        theme: ThemeData(
          canvasColor: Colors.white,
          primaryColor: Colors.black,
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              overlayColor: MaterialStateProperty.all<Color>(
                  Colors.black.withOpacity(0.1)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              overlayColor: MaterialStateProperty.all<Color>(
                  Colors.white.withOpacity(0.1)),
              shape: MaterialStateProperty.all(
                ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all<double>(10.0),
              overlayColor: MaterialStateProperty.all<Color>(
                  Colors.black.withOpacity(0.1)),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(
                    width: 2, color: Colors.black, style: BorderStyle.solid),
              ),
            ),
          ),
        ),
        home: Scaffold(
          body: Consumer(
            builder: (context, watch, _) {
              if (shouldUseAnimatedSwitcher) {
                return AnimatedSwitcher(
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      child: FadeTransition(
                        child: child,
                        opacity: animation,
                      ),
                      scale: animation,
                    );
                  },
                  duration: Duration(seconds: 1),
                  child: _watchAuthState(watch, context),
                );
              } else {
                return _watchAuthState(watch, context);
              }
            },
          ),
        ));
  }
}
