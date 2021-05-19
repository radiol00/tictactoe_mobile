import 'package:wand_tictactoe/models/player.dart';

class GameState {
  String id;
  List<List<Figure>> board;
  Player enemyInfo;
  Figure playerFigure;
  Figure enemyFigure;
  Turn turn;

  GameState(Figure fig) {
    if (fig == Figure.X) {
      playerFigure = Figure.X;
      turn = Turn.PLAYER;
    } else {
      playerFigure = Figure.O;
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
