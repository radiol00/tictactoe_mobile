import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/enums/enums.dart';
import 'package:wand_tictactoe/models/game_result.dart';
import 'package:wand_tictactoe/models/game_state.dart';
import 'package:wand_tictactoe/models/player.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';
import 'package:wand_tictactoe/services/wand_shared_preferences.dart';

final gameController =
    StateNotifierProvider.autoDispose<GameNotifier, AsyncValue<GameState>>(
  (ref) => GameNotifier(
    ref.read(wandFirebaseConnection),
    ref.read(wandSharedPreferencesProvider),
  ),
);

class GameNotifier extends StateNotifier<AsyncValue<GameState>> {
  GameNotifier(this._connection, this._prefs) : super(AsyncValue.loading()) {
    init();
  }

  WANDFirebaseConnection _connection;
  WANDSharedPreferences _prefs;
  GameState gameState;

  void init() async {
    await _prefs.ensureInitialized();
    String gameId = _prefs.getGameId();

    if (gameId == "") {
      state = AsyncValue.data(null);
    } else {
      joinGame(gameId);
      refreshState();
    }
  }

  void refreshState() {
    state = AsyncValue.data(gameState);
  }

  Future<void> placeFigure(int x, int y) async {
    if (gameState.turn == Turn.PLAYER) {
      gameState.board[x][y] = gameState.playerFigure;
      gameState.turn = Turn.ENEMY;
      DocumentReference gameDoc = _connection.getGameDoc(gameState.id);
      var doc = await gameDoc.get();
      Map board = doc["board"];
      board["$x$y"] = gameState.playerFigure == Figure.X ? 1 : 2;
      gameDoc.update({"board": board, "turn": gameState.enemyInfo.uid});

      refreshState();
    }
    return;
  }

  Future<void> joinGame(String gameId) async {
    try {
      DocumentReference gameDoc = _connection.getGameDoc(gameId);
      DocumentSnapshot data = await gameDoc.get();
      await _prefs.setGameId(gameId);

      gameState = await prepareGameState(data);
      gameState.id = gameId;

      _connection.getGameStream(gameId).listen(
        gameStreamHandler,
        onError: (err) {
          print("Game Stream error: $err");
        },
      );

      refreshState();
    } catch (e) {
      leaveGame();
      print(e);
      throw new FirebaseException(plugin: 'FireStore');
    }
  }

  // GAME STREAM!!!
  void gameStreamHandler(DocumentSnapshot<Map<String, dynamic>> doc) {
    print("UPDATED GAME ${DateTime.now()}");
    Map board = doc.data()["board"];
    String turn = doc.data()["turn"];
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        Figure figure = Figure.BLANK;
        int figureId = board["$i$j"];
        if (figureId == 1) {
          figure = Figure.X;
        } else if (figureId == 2) {
          figure = Figure.O;
        }
        gameState.board[i][j] = figure;
      }
    }

    gameState.result = checkGameResult(gameState.board);

    if (turn == _connection.auth.currentUser.uid) {
      gameState.turn = Turn.PLAYER;
    } else {
      gameState.turn = Turn.ENEMY;
    }
    // TODO: SET PLAYER AND ENEMY FIGURES!!!!!
    refreshState();
  }

  GameResult checkGameResult(List<List<Figure>> b) {
    // row 0
    if (b[0][0] != Figure.BLANK && b[0][0] == b[0][1] && b[0][1] == b[0][2])
      return GameResult(
        start: Alignment.topLeft,
        end: Alignment.topRight,
        figure: b[0][0],
      );

    // row 1
    if (b[1][0] != Figure.BLANK && b[1][0] == b[1][1] && b[1][1] == b[1][2])
      return GameResult(
        start: Alignment.centerLeft,
        end: Alignment.centerRight,
        figure: b[1][0],
      );

    // row 2
    if (b[2][0] != Figure.BLANK && b[2][0] == b[2][1] && b[2][1] == b[2][2])
      return GameResult(
        start: Alignment.bottomLeft,
        end: Alignment.bottomRight,
        figure: b[2][0],
      );

    // column 0
    if (b[0][0] != Figure.BLANK && b[0][0] == b[1][0] && b[1][0] == b[2][0])
      return GameResult(
        start: Alignment.topLeft,
        end: Alignment.bottomLeft,
        figure: b[0][0],
      );

    // column 1
    if (b[0][1] != Figure.BLANK && b[0][1] == b[1][1] && b[1][1] == b[2][1])
      return GameResult(
        start: Alignment.topCenter,
        end: Alignment.bottomCenter,
        figure: b[0][1],
      );

    // column 2
    if (b[0][2] != Figure.BLANK && b[0][2] == b[1][2] && b[1][2] == b[2][2])
      return GameResult(
        start: Alignment.topRight,
        end: Alignment.bottomRight,
        figure: b[0][2],
      );

    // diagonal 1
    if (b[0][0] != Figure.BLANK && b[0][0] == b[1][1] && b[1][1] == b[2][2])
      return GameResult(
        start: Alignment.topLeft,
        end: Alignment.bottomRight,
        figure: b[0][0],
      );

    // diagonal 2
    if (b[2][0] != Figure.BLANK && b[2][0] == b[1][1] && b[1][1] == b[0][2])
      return GameResult(
        start: Alignment.bottomLeft,
        end: Alignment.topRight,
        figure: b[2][0],
      );

    bool isDraw = true;
    for (var i = 0; i < 2; i++) {
      for (var j = 0; j < 2; j++) {
        if (b[i][j] == Figure.BLANK) {
          isDraw = false;
        }
      }
    }

    if (isDraw)
      return GameResult(start: null, end: null, figure: null)..draw = true;

    return null;
  }

  Future<GameState> prepareGameState(DocumentSnapshot gameDoc) async {
    GameState gs = GameState();
    List<dynamic> gameUsers = gameDoc["users"];
    String enemyUID;
    Player enemy = Player();
    String playerUID = _connection.auth.currentUser.uid;

    // GET ENEMY UID
    if (gameUsers[0] == playerUID) {
      enemyUID = gameUsers[1];
    } else {
      enemyUID = gameUsers[0];
    }

    // GET ENEMY DOC + INFO
    // TODO: UNCOMMENT CODE BELOW
    var enemyDoc = await _connection.getPlayerDoc(enemyUID);
    enemy.uid = enemyUID;
    enemy.displayName = enemyDoc["displayName"];
    enemy.draws = enemyDoc["draws"];
    enemy.loses = enemyDoc["loses"];
    enemy.wins = enemyDoc["wins"];
    // enemy.uid = "asd";
    // enemy.displayName = "ENEMY";
    // enemy.draws = 1;
    // enemy.loses = 2;
    // enemy.wins = 3;
    gs.enemyInfo = enemy;

    return gs;
  }

  void leaveGame() async {
    await _prefs.setGameId("");
    state = AsyncValue.data(null);
  }
}
