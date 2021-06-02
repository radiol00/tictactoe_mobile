import 'package:wand_tictactoe/models/game_result.dart';
import 'package:wand_tictactoe/models/player.dart';
import 'package:wand_tictactoe/enums/enums.dart';

class GameState {
  String id;
  List<List<Figure>> board;
  Stream<Map<String, Figure>> boardStream;
  Player enemyInfo;
  Figure playerFigure;
  Figure enemyFigure;
  Turn turn;
  GameResult result;

  GameState() {
    board = [
      [Figure.BLANK, Figure.BLANK, Figure.BLANK],
      [Figure.BLANK, Figure.BLANK, Figure.BLANK],
      [Figure.BLANK, Figure.BLANK, Figure.BLANK],
    ];
  }

  // setFirstTurn(Turn firstTurn) {
  //   if (firstTurn == Turn.PLAYER) {
  //     playerFigure = Figure.X;
  //     enemyFigure = Figure.O;
  //     turn = Turn.PLAYER;
  //   } else {
  //     playerFigure = Figure.O;
  //     enemyFigure = Figure.X;
  //     turn = Turn.ENEMY;
  //   }

  // }
}
