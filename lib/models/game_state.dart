import 'package:wand_tictactoe/models/player.dart';

class GameState {
  String id;
  List<List<Figure>> board;
  Stream<Map<String, Figure>> boardStream;
  Player enemyInfo;
  Figure playerFigure;
  Figure enemyFigure;
  Turn turn;

  setFirstTurn(Turn firstTurn) {
    if (firstTurn == Turn.PLAYER) {
      playerFigure = Figure.X;
      enemyFigure = Figure.O;
      turn = Turn.PLAYER;
    } else {
      playerFigure = Figure.O;
      enemyFigure = Figure.X;
      turn = Turn.ENEMY;
    }

    board = [
      [Figure.BLANK, Figure.BLANK, Figure.BLANK],
      [Figure.BLANK, Figure.BLANK, Figure.BLANK],
      [Figure.BLANK, Figure.BLANK, Figure.BLANK],
    ];
  }
}

enum Turn { ENEMY, PLAYER }

enum Figure { BLANK, X, O }
