import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';

enum MockFirebaseAuthNotifierMode {
  noInteraction,
  successfulInteraction,
  failedInteraction
}

class MockFirebaseAuthNotifier extends FirebaseAuthNotifier {
  MockFirebaseAuthNotifier(MockFirebaseAuthNotifierMode mode) : super(null) {
    _mode = mode;
  }

  MockFirebaseAuthNotifierMode _mode;

  @override
  void init() async {
    state = AsyncValue.data(null);
  }

  @override
  Future<void> registerWithEmailAndPasswd(
      String email, String passwd, String username) async {
    switch (_mode) {
      case MockFirebaseAuthNotifierMode.noInteraction:
        return;
      case MockFirebaseAuthNotifierMode.successfulInteraction:
        state = AsyncValue.data(TTTUser());
        return;
      case MockFirebaseAuthNotifierMode.failedInteraction:
        throw new FirebaseAuthException(code: "test", message: "test message");
        return;
    }
  }

  Stream<String> get userDisplayNameStream {
    return Stream.value("test");
  }

  @override
  Future<void> loginWithEmailAndPasswd(String email, String passwd) async {
    switch (_mode) {
      case MockFirebaseAuthNotifierMode.noInteraction:
        return;
      case MockFirebaseAuthNotifierMode.successfulInteraction:
        state = AsyncValue.data(TTTUser());
        return;
      case MockFirebaseAuthNotifierMode.failedInteraction:
        throw new FirebaseAuthException(code: "test", message: "test message");
        return;
    }
  }
}
