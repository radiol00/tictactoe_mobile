import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/models/ttt_user.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';

final firebaseAuthController = StateNotifierProvider.autoDispose<
        FirebaseAuthNotifier, AsyncValue<TTTUser>>(
    (ref) => FirebaseAuthNotifier(ref.read(wandFirebaseConnection)));

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
          localUser = tttuser;
          state = AsyncValue.data(tttuser);
        }
      });
  }

  Stream<String> get userDisplayNameStream {
    Stream<User> userChanges = _connection.auth.userChanges();
    StreamTransformer<User, String> displayNameStreamDecapsulation =
        StreamTransformer<User, String>.fromHandlers(
      handleData: (User data, sink) {
        sink.add(data.displayName);
      },
    );
    return userChanges.transform(displayNameStreamDecapsulation);
  }

  String get uid {
    if (localUser != null)
      return localUser.firebaseUserObject.uid;
    else
      return "";
  }

  Future<void> registerWithEmailAndPasswd(
      String email, String passwd, String username) async {
    username = username.trim();
    email = email.trim();
    passwd = passwd.trim();
    var user = await _connection.auth
        .createUserWithEmailAndPassword(email: email, password: passwd);
    await user.user.updateProfile(displayName: username);
    await _connection.store.collection("users").doc(user.user.uid).set({
      "displayName": username,
      "wins": 0,
      "loses": 0,
      "draws": 0,
      "currentWinStreak": 0,
      "maxWinStreak": 0,
    });
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

  void changePasswd() async {
    await _connection.auth
        .sendPasswordResetEmail(email: localUser.firebaseUserObject.email);
  }
}
