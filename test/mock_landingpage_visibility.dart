import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/services/wand_shared_preferences.dart';

class MockLandingPageVisibilityNotifier extends LandingPageVisibilityNotifier {
  MockLandingPageVisibilityNotifier({this.done}) : super(null);

  bool done;

  @override
  void init() {
    state = AsyncValue.data(done);
    return;
  }

  @override
  void seen() {
    return;
  }
}
