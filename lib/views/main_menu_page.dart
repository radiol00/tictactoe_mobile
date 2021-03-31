import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';

class MainMenuPage extends StatefulWidget {
  MainMenuPage({this.key, this.delayInitAnimations = false}) : super(key: key);
  final Key key;
  final bool delayInitAnimations;
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage>
    with TickerProviderStateMixin {
  Function logout;
  AnimationController _animationController;
  Animation _animationMenuButtons;
  Animation _animationProfileButton;
  CurvedAnimation _animationMenuButtonsCurve;

  CurvedAnimation _animationProfileButtonCurve;
  int menuButtonId = 0;
  bool onGoingAnimation = true;
  bool menuItemsVisible = false;
  String username;

  @override
  void initState() {
    super.initState();
    logout = context.read(firebaseAuthController).logout;
    username = context.read(localTTTUserProvider)?.firebaseUserObject?.email;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animationMenuButtonsCurve =
        CurvedAnimation(parent: _animationController, curve: Curves.bounceOut);

    _animationProfileButtonCurve = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic);

    _animationProfileButton =
        Tween<double>(begin: 1, end: 0).animate(_animationProfileButtonCurve)
          ..addListener(() {
            setState(() {});
          });

    _animationMenuButtons =
        Tween<double>(begin: 1, end: 0).animate(_animationMenuButtonsCurve)
          ..addListener(() {
            setState(() {});
          });

    if (widget.delayInitAnimations)
      runAnimationsWithDelay();
    else
      runAnimationsWithoutDelay();
  }

  void runAnimationsWithoutDelay() async {
    if (mounted) {
      setState(() {
        menuItemsVisible = true;
      });
      _animationController.forward().then((value) {
        setState(() {
          onGoingAnimation = false;
        });
      });
    }
  }

  void runAnimationsWithDelay() async {
    Timer(Duration(seconds: 1), () {
      Timer.periodic(Duration(milliseconds: 300), (timer) {
        if (!KeyboardVisibilityProvider.isKeyboardVisible(context)) {
          runAnimationsWithoutDelay();
          timer.cancel();
        }
      });
    });
  }

  Widget _buildMenuButton(
    String text,
  ) {
    bool isEven = menuButtonId % 2 == 0;
    menuButtonId += 1;

    double xOffset = isEven
        ? _animationMenuButtons.value * MediaQuery.of(context).size.width
        : _animationMenuButtons.value * -MediaQuery.of(context).size.width;

    return Transform.translate(
      offset: Offset(xOffset, 0),
      child: Transform.rotate(
        angle: xOffset / 1000,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            width: 250.0,
            height: 50,
            child: OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              onPressed: () {
                print(onGoingAnimation);
              },
              child: Text("$text"),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    menuButtonId = 0;

    return SafeArea(
      child: Column(
        children: [
          Placeholder(
            fallbackHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (menuItemsVisible)
                      Transform.translate(
                        offset: Offset(
                            _animationProfileButton.value *
                                MediaQuery.of(context).size.width,
                            0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 25.0,
                                    ),
                                    Text(
                                      "$username",
                                      style: TextStyle(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (menuItemsVisible)
                      Column(
                        children: [
                          _buildMenuButton("Find match"),
                          _buildMenuButton("Fight with friend"),
                        ],
                      ),
                    if (menuItemsVisible)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Transform.translate(
                              offset:
                                  Offset(0, _animationMenuButtons.value * 100),
                              child: IconButton(
                                splashRadius:
                                    Material.defaultSplashRadius - 10.0,
                                icon: Icon(Icons.settings),
                                iconSize: 35,
                                onPressed: () {
                                  if (!onGoingAnimation) {
                                    logout();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
