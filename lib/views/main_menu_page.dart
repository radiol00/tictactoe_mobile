import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';
import 'package:wand_tictactoe/providers/game_controller_provider.dart';
import 'package:wand_tictactoe/providers/grpc_provider.dart';
import 'package:wand_tictactoe/providers/protip_provider.dart';
import 'package:wand_tictactoe/views/credits_page.dart';
import 'package:wand_tictactoe/views/profile_page.dart';
import 'package:wand_tictactoe/views/settings_page.dart';
import 'package:wand_tictactoe/widgets/wand_progress_indicator.dart';

import 'package:wand_tictactoe/proto/ttt_service.pbgrpc.dart' as proto;
import 'package:wand_tictactoe/widgets/wand_snackbar.dart';

class MainMenuPage extends StatefulWidget {
  MainMenuPage({this.key, this.delayInitAnimations = false}) : super(key: key);
  final Key key;
  final bool delayInitAnimations;
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage>
    with TickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _animationController;
  Animation _animationMenuButtons;
  Animation _animationProfileButton;
  CurvedAnimation _animationMenuButtonsCurve;
  WANDgRPCConnection grpc;
  Future<void> Function(String) joinGame;

  CurvedAnimation _animationProfileButtonCurve;
  int menuButtonId = 0;
  bool onGoingAnimation = true;
  bool menuItemsVisible = false;
  Protip protip;
  Timer protipTimer;
  String userId;

  Stream<String> userDisplayNameStream;

  void randomizeProtip() {
    List<Protip> result = context.read(protipProvider);
    var copy = result.toList();
    final _random = Random();
    copy.removeWhere(
        (element) => protip == null ? false : element.id == protip.id);
    setState(() {
      protip = copy[_random.nextInt(copy.length)];
    });
  }

  void runProtipAnimationTimer() {
    protipTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels == 0)
        await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut);
      await Future.delayed(Duration(seconds: 3));
      if (_scrollController.hasClients)
        await _scrollController.animateTo(0,
            duration: Duration(seconds: 2), curve: Curves.easeInOut);
      if (mounted)
        randomizeProtip();
      else
        timer.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    joinGame = context.read(gameController.notifier).joinGame;
    grpc = context.read(grpcProvider);
    userId = context.read(firebaseAuthController.notifier).uid;

    _scrollController = ScrollController();

    randomizeProtip();
    runProtipAnimationTimer();
    userDisplayNameStream =
        context.read(firebaseAuthController.notifier).userDisplayNameStream;
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
    Function onPressed,
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
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onPressed: onPressed,
              child: Text("$text"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Opacity(
      opacity: -(_animationProfileButton.value - 1),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage("assets/mm_background.png"),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Transform.translate(
      offset: Offset(
          _animationProfileButton.value * MediaQuery.of(context).size.width, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent)),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProfilePage(userId: userId),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 25.0,
                  ),
                  StreamBuilder(
                    stream: userDisplayNameStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "${snapshot.data}",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else
                        return Text("");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: -(_animationProfileButton.value - 1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                customBorder: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                splashColor: Colors.black.withOpacity(0.1),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreditsPage(),
                  ));
                },
                child: SizedBox(
                  height: 50,
                  child: Hero(
                    tag: "Credits_WAND_logo",
                    child: Image.asset("assets/credits.png"),
                  ),
                ),
              ),
            ),
          ),
          OpenContainer(
            closedShape: CircleBorder(),
            closedElevation: 0,
            openElevation: 0,
            tappable: false,
            closedBuilder: (context, openContainer) {
              return Transform.translate(
                offset: Offset(0, _animationMenuButtons.value * 100),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    splashRadius: Material.defaultSplashRadius - 10.0,
                    icon: Icon(Icons.settings),
                    iconSize: 35,
                    onPressed: () {
                      if (!onGoingAnimation) {
                        openContainer();
                      }
                    },
                  ),
                ),
              );
            },
            openBuilder: (context, closeContainer) {
              return SettingsPage(
                popPage: closeContainer,
              );
            },
          ),
        ],
      ),
    );
  }

  void popAndShowError(String err) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      buildSnackBar(context, err),
    );
  }

  void findMatch() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildMMDialog(),
    );
    grpc.dial();
    Stream<proto.Response> stream = grpc.joinMatchmaking();

    // Error in getting stream, display error
    if (stream == null) {
      popAndShowError("There was an error in joining match making");
      return;
    }

    // TIMEOUT TIMER, display connection error
    var timer = Timer(Duration(seconds: 3), () {
      grpc.leaveMatchmaking();
      popAndShowError("Problem with connection: timeout");
      return;
    });

    try {
      // await the first Response from stream (supposed to be HandShake)
      var firstResponse = await stream.first;

      // if it is HandShake, everything's OK
      if (firstResponse.hasHandshake()) {
        // Server is live because got HandShake, timeout timer can be canceled
        timer.cancel();

        // awaiting the second Response (supposed to be Game object with its id)
        proto.Response gameIDResponse = await stream.first;

        // Got response, leave matchmaking.
        grpc.leaveMatchmaking();
        Navigator.of(context).pop();

        // if it is GameID, everything's OK
        if (gameIDResponse.hasGameId()) {
          // Join game that's under gameid
          try {
            await joinGame(gameIDResponse.gameId.id);
          } catch (e) {
            if (e is FirebaseException) {
              print(e);
              ScaffoldMessenger.of(context).showSnackBar(
                buildSnackBar(context,
                    "There was an error in match making: no such game"),
              );
              return;
            }
          }
        } else {
          // not GameID, error!
          grpc.leaveMatchmaking();
          popAndShowError(
              "There was an error in match making: invalid response GameID");
          return;
        }
      } else {
        // Not HandShake error!
        timer.cancel();
        grpc.leaveMatchmaking();
        popAndShowError(
            "There was an error in match making: invalid response HandShake");
        return;
      }
    } catch (e) {
      if (e is GrpcError && e.code == 1) {
        timer.cancel();
      } else {
        timer.cancel();
        print(e);
      }
    }
  }

  Widget _buildMMDialog() {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.white60,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WANDProgressIndicator(
              type: WANDProgressIndicatorType.fullscreen,
            ),
            SizedBox(
              height: 40.0,
            ),
            Text("Looking for opponent..."),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  grpc.leaveMatchmaking();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"))
          ],
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
          Image.asset(
            "assets/game_title.png",
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          Opacity(
            opacity: -(_animationProfileButton.value - 1),
            child: SizedBox(
              height: 20,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        "Protip: ${protip?.text}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Stack(
              children: [
                _buildBackground(),
                if (menuItemsVisible) _buildProfileButton(),
                if (menuItemsVisible)
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMenuButton("Find match", findMatch),
                        _buildMenuButton("Fight with friend", () {}),
                      ],
                    ),
                  ),
                if (menuItemsVisible) _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    protipTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
