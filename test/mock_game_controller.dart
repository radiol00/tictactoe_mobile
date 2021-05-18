import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/game_controller_provider.dart';

class MockGameNotifier extends GameNotifier {
  MockGameNotifier() : super(null, null);

  @override
  void init() async {
    state = AsyncValue.data(null);
  }

  @override
  Future<void> joinGame(String gameId) async {
    return;
  }

  @override
  void leaveGame() async {
    return;
  }
}
