import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wand_tictactoe/enums/enums.dart';
import 'package:wand_tictactoe/models/game_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/player.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';
import 'package:wand_tictactoe/providers/game_controller_provider.dart';
import 'package:wand_tictactoe/widgets/game_result_painter.dart';

class GamePage extends StatefulWidget {
  GamePage({this.gameState});
  final GameState gameState;
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String settingsHeroIconTag = "IN_GAME_SETTINGS";
  Future<void> Function(int, int) placeFigure;
  void Function() leaveGame;
  String playerName = "";
  Player enemyInfo;
  bool resultPopped = false;
  int _quantityOfFigureVisages = 10;

  @override
  void initState() {
    super.initState();
    placeFigure = context.read(gameController.notifier).placeFigure;
    leaveGame = context.read(gameController.notifier).leaveGame;
    playerName = context
        .read(firebaseAuthController.notifier)
        .localUser
        .firebaseUserObject
        .displayName;

    enemyInfo = widget.gameState.enemyInfo;
  }

  Widget _buildEnemyInfo() {
    Figure enemyFigure = widget.gameState.enemyFigure;
    Widget enemyFigureWidget = Text(
      "O",
      textScaleFactor: 1.3,
    );

    if (enemyFigure == Figure.X)
      enemyFigureWidget = Text(
        "X",
        textScaleFactor: 1.3,
      );

    return Expanded(
      child: Column(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${enemyInfo.displayName}",
                    textScaleFactor: 1.8,
                  ),
                  Text(
                    "${enemyInfo.wins} - ${enemyInfo.draws} - ${enemyInfo.loses}",
                    textScaleFactor: 1.3,
                  ),
                ],
              ),
              Row(
                children: [
                  enemyFigureWidget,
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    Figure playerFigure = widget.gameState.playerFigure;
    Widget playerFigureWidget = Text(
      "O",
      textScaleFactor: 1.3,
    );

    if (playerFigure == Figure.X)
      playerFigureWidget = Text("X", textScaleFactor: 1.3);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  playerFigureWidget,
                  Text(
                    "$playerName",
                    textScaleFactor: 1.8,
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    child: Hero(
                      tag: settingsHeroIconTag,
                      child: Icon(
                        Icons.settings,
                        size: 35,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          barrierColor: Colors.black.withAlpha(50),
                          opaque: false,
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Hero(
                                              tag: settingsHeroIconTag,
                                              child: Icon(
                                                Icons.settings,
                                                size: 35,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Colors.white.withAlpha(200),
                                                ),
                                                foregroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                            (states) {
                                                  return states.contains(
                                                          MaterialState.pressed)
                                                      ? Colors.black
                                                      : Colors.white;
                                                }),
                                              ),
                                              onLongPress: () async {
                                                Navigator.of(context).pop();
                                                leaveGame();
                                              },
                                              onPressed: () {},
                                              child: Text("Leave game"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Icon(
                                            Icons.chevron_left_rounded,
                                            size: 35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoardGrid() {
    Widget _buildField(int x, int y) {
      String path = "assets";
      Figure figure = widget.gameState.board[x][y];

      Widget figureWidget = Container();
      if (widget.gameState.id != null) {
        if (figure == Figure.O) {
          path += "/oes/";
        } else if (figure == Figure.X) {
          path += "/xes/";
        }

        if (figure == Figure.O || figure == Figure.X) {
          int calculatedFigurePicID = widget.gameState.id.codeUnitAt(0) +
              x * widget.gameState.id.codeUnitAt(1) +
              y * widget.gameState.id.codeUnitAt(2) +
              x +
              y;

          path += "${calculatedFigurePicID % _quantityOfFigureVisages}";

          path += ".png";
          figureWidget = Image.asset(path);
        }
      }

      return GestureDetector(
        child: Container(
          color: Colors.white,
          child: FittedBox(
            child: figureWidget,
          ),
        ),
        onTap: () {
          placeFigure(x, y);
        },
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 1.5,
              ),
            ),
            color: Colors.black),
        child: GridView.count(
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 3,
          children: [
            _buildField(0, 0),
            _buildField(0, 1),
            _buildField(0, 2),
            _buildField(1, 0),
            _buildField(1, 1),
            _buildField(1, 2),
            _buildField(2, 0),
            _buildField(2, 1),
            _buildField(2, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildGameResultLayer() {
    if (widget.gameState.result == null) return Container();
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 60,
          right: 60,
          bottom: 60,
          top: 60,
        ),
        child: CustomPaint(
          painter: GameResultPainter(
            widget.gameState.result,
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.gameState.turn == Turn.ENEMY ? "ENEMY TURN" : ""),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30.0,
          ),
          child: Stack(
            children: [
              _buildBoardGrid(),
              _buildGameResultLayer(),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.gameState.turn == Turn.PLAYER ? "YOUR TURN" : ""),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameState.result != null && !resultPopped) {
      resultPopped = true;
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            barrierColor: Colors.black.withAlpha(50),
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.gameState.result.draw
                                  ? "DRAW"
                                  : widget.gameState.result.figure ==
                                          widget.gameState.playerFigure
                                      ? "WIN"
                                      : "LOSE",
                              textScaleFactor: 2.0,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all<Color>(
                                  Colors.white.withAlpha(200),
                                ),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return states.contains(MaterialState.pressed)
                                      ? Colors.black
                                      : Colors.white;
                                }),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                leaveGame();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEnemyInfo(),
              _buildBoard(),
              _buildPlayerInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
