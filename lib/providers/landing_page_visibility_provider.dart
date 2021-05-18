import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/services/wand_shared_preferences.dart';

// CONTROLLER
final landingPageVisibilityController = StateNotifierProvider.autoDispose<
    LandingPageVisibilityNotifier, AsyncValue<bool>>(
  (ref) =>
      LandingPageVisibilityNotifier(ref.read(wandSharedPreferencesProvider)),
);

// NOTIFIER
class LandingPageVisibilityNotifier extends StateNotifier<AsyncValue<bool>> {
  LandingPageVisibilityNotifier(this.prefs) : super(AsyncValue.loading()) {
    init();
  }

  WANDSharedPreferences prefs;

  void init() async {
    await prefs.ensureInitialized();
    // state = AsyncValue.data(false);
    state = AsyncValue.data(prefs.getLandingPageSeen());
  }

  void seen() {
    prefs.setLandingPageSeen();
  }
}
