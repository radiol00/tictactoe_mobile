import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/game_state.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';
import 'package:wand_tictactoe/services/wand_shared_preferences.dart';

final gameController = StateNotifierProvider.autoDispose<GameNotifier>(
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

  void init() async {
    await _prefs.ensureInitialized();
    String gameId = _prefs.getGameId();
    if (gameId == "") {
      state = AsyncValue.data(null);
    } else {
      // RETRIEVE GAME STATE !!!
      GameState gameState = GameState()..id = gameId;
      state = AsyncValue.data(gameState);
    }
  }

  Future<void> joinGame(String gameId) async {
    // TRY TO JOIN GAME
    // IF JOIN SUCCESSFUL
    try {
      DocumentReference gameDoc = _connection.getGameDoc(gameId);
      DocumentSnapshot data = await gameDoc.get();
      print(data);
      await _prefs.setGameId(gameId);

      GameState gameState = GameState()..id = gameId;
      state = AsyncValue.data(gameState);
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
