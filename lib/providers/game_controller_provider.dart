import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // TODO: RETRIEVE GAME STATE !!!
      // gameState = GameState()..id = gameId;
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
    // TRY TO JOIN GAME
    // IF JOIN SUCCESSFUL
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
    // ELSE
  }

  // GAME STREAM!!!
  void gameStreamHandler(DocumentSnapshot<Map<String, dynamic>> doc) {
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
    if (turn == _connection.auth.currentUser.uid) {
      gameState.turn = Turn.PLAYER;
    }
    refreshState();
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

    // SET FIRST TURN
    if (gameDoc["turn"] == playerUID) {
      gs.setFirstTurn(Turn.PLAYER);
    } else {
      gs.setFirstTurn(Turn.ENEMY);
    }
    return gs;
  }

  void leaveGame() async {
    await _prefs.setGameId("");
    state = AsyncValue.data(null);
  }
}
