// CONTROLLER
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';

final firebaseAuthController = StateNotifierProvider.autoDispose(
    (ref) => FirebaseAuthNotifier(ref.read(wandFirebaseConnection)));

class FirebaseAuthNotifier extends StateNotifier<AsyncValue<TTTUser>> {
  FirebaseAuthNotifier(this._connection) : super(AsyncValue.loading()) {
    _init();
  }
  WANDFirebaseConnection _connection;

  void _init() async {
    if (_connection.auth.currentUser == null) {
      state = AsyncValue.data(null);
      return;
    }
    TTTUser user = TTTUser()..firebaseUserObject = _connection.auth.currentUser;
    // print(_connection.store.getUsername(user.firebaseUserObject.uid));
    state = AsyncValue.data(user);
    return;
  }

  Future<dynamic> registerWithEmailAndPasswd(
      String email, String passwd) async {
    await _connection.auth
        .createUserWithEmailAndPassword(email: email, password: passwd);
  }

  void logout() async {
    await _connection.auth.signOut();
  }
}
