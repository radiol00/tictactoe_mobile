import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';

final firebaseAuthController =
    StateNotifierProvider.autoDispose<FirebaseAuthNotifier>(
        (ref) => FirebaseAuthNotifier(ref.read(wandFirebaseConnection)));

final localTTTUserProvider =
    Provider((ref) => ref.read(firebaseAuthController).localUser);

class FirebaseAuthNotifier extends StateNotifier<AsyncValue<TTTUser>> {
  FirebaseAuthNotifier(this._connection) : super(AsyncValue.loading()) {
    init();
  }
  WANDFirebaseConnection _connection;

  TTTUser localUser;

  void init() async {
    _connection.auth.authStateChanges()
      ..listen((user) {
        if (user == null) {
          localUser = null;
          state = AsyncValue.data(null);
        } else {
          TTTUser tttuser = TTTUser()..firebaseUserObject = user;
          state = AsyncValue.data(tttuser);
          localUser = tttuser;
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
