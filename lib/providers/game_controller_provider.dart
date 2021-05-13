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

  void init() async {
    // GET GAMEID FROM PREFERENCES !!!
    await _prefs.ensureInitialized();
    String gameId = "";
    if (gameId == "") {
      state = AsyncValue.data(null);
    }
  }

  void joinGame(String gameId) {
    // TRY TO JOIN GAME
    GameState gameState = GameState()..id = gameId;
    state = AsyncValue.data(gameState);
  }

  WANDFirebaseConnection _connection;
  WANDSharedPreferences _prefs;
}
