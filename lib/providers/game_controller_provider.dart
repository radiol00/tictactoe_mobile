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

    // TODO: REMEMBER TO DELETE CODE BELOW
    // ONLY FOR DEV PURPOSES, TO BE DELETED
    // gameState = GameState(Figure.X);
    // gameState.id = "123";
    // gameState.enemyFigure = Figure.O;
    // gameState.playerFigure = Figure.X;
    // gameState.turn = Turn.PLAYER;
    // gameState.enemyInfo = Player()
    //   ..displayName = "ENEMY"
    //   ..draws = 0
    //   ..wins = 3
    //   ..loses = 2;
    // refreshState();
    // return;
    // ----------------------

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
      print(data);
      await _prefs.setGameId(gameId);

      gameState.id = gameId;
      refreshState();
    } catch (e) {
      leaveGame();
      throw new FirebaseException(plugin: 'FireStore');
    }
    // ELSE
  }

  void leaveGame() async {
    await _prefs.setGameId("");
    state = AsyncValue.data(null);
  }
}
