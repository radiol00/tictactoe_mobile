// CONTROLLER
import 'package:firebase_auth/firebase_auth.dart';
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
    _connection.auth.authStateChanges()
      ..listen((user) {
        if (user == null) {
          state = AsyncValue.data(null);
        } else {
          state = AsyncValue.data(TTTUser()..firebaseUserObject = user);
        }
      });
  }

  Future<void> registerWithEmailAndPasswd(String email, String passwd) async {
    email = email.trim();
    passwd = passwd.trim();
    await _connection.auth
        .createUserWithEmailAndPassword(email: email, password: passwd);
  }

  Future<void> loginWithEmailAndPasswd(String email, String passwd) async {
    email = email.trim();
    passwd = passwd.trim();

    await _connection.auth
        .signInWithEmailAndPassword(email: email, password: passwd);
  }

  void logout() async {
    _connection.auth.signOut();
  }
}
