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
      // state = AsyncValue.data(gameState);
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

      gameDoc.update({
        "board": {"$x$y", 3}
      });

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
      _connection.getGameStream(gameId).listen((event) {
        print(event);
        refreshState();
      });

      refreshState();
    } catch (e) {
      leaveGame();
      print(e);
      throw new FirebaseException(plugin: 'FireStore');
    }
    // ELSE
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
    var enemyDoc = await _connection.getPlayerDoc(enemyUID);
    enemy.displayName = enemyDoc["displayName"];
    enemy.draws = enemyDoc["draws"];
    enemy.loses = enemyDoc["loses"];
    enemy.wins = enemyDoc["wins"];
    gs.enemyInfo = enemy;

    // SET FIRST TURN
    if (gameDoc["turn"] == playerUID) {
      gs.setFirstTurn(Turn.PLAYER);
    } else {
      gs.setFirstTurn(Turn.ENEMY);
    }
    return gs;
  }

  Stream<Map<String, Figure>> getBoardStream(String gameId) {
    var gameStream = _connection.getGameStream(gameId);
    StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
            Map<String, Figure>> boardStreamDecapsulation =
        StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
            Map<String, Figure>>.fromHandlers(
      handleData: (DocumentSnapshot<Map<String, dynamic>> data, sink) {
        Map<String, dynamic> boardMap = data["board"];
        Map<String, Figure> boardFigureMap = {};
        boardMap.forEach((key, value) {
          if (value == 1)
            boardFigureMap[key] = Figure.X;
          else if (value == 2)
            boardFigureMap[key] = Figure.O;
          else
            boardFigureMap[key] = Figure.BLANK;
        });
        sink.add(boardFigureMap);
      },
    );
    return gameStream.transform(boardStreamDecapsulation);
  }

  void leaveGame() async {
    await _prefs.setGameId("");
    state = AsyncValue.data(null);
  }
}
