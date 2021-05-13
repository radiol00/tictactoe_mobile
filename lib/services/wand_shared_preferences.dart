import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// wandSharedPreferencesProvider provides WANDSharedPreferences object and every
/// functionality that comes with it. It shouldn't be used directly in UI oriented code.
/// Please create separate provider that additionaly ensures wandSharedPreferencesProvider is
/// correctly initialized using its [ensureInitialized()] asynchronous function.
final wandSharedPreferencesProvider = Provider<WANDSharedPreferences>(
  (ref) => WANDSharedPreferences(),
);

class WANDSharedPreferences {
  SharedPreferences sp;
  String landingPageSeenKey = "WAND_LANDING_PAGE_SEEN";
  String gameIdKey = "WAND_GAME_ID";

  bool get isUninitialized => sp == null ? true : false;

  void checkInitialization() {
    if (isUninitialized)
      throw new Exception("Shared Preferences not initialized!");
  }

  Future<void> _init() async {
    sp = await SharedPreferences.getInstance();
    return;
  }

  /// ensureInitialized() should be called before every WANDSharedPreferences API usage,
  /// it makes sure that everything is initialized.
  Future<void> ensureInitialized() async {
    if (isUninitialized) await _init();
  }

  bool getLandingPageSeen() {
    checkInitialization();
    final result = sp.getBool(landingPageSeenKey);
    if (result != null) return result;
    return false;
  }

  Future<void> setLandingPageSeen() async {
    checkInitialization();
    await sp.setBool(landingPageSeenKey, true);
    return;
  }

  Future<void> setGameId(gameId) async {
    checkInitialization();
    await sp.setString(gameIdKey, gameId);
    return;
  }

  String getGameId() {
    checkInitialization();
    final result = sp.getString(gameIdKey);
    if (result != null && result != "") return result;
    return "";
  }
}
