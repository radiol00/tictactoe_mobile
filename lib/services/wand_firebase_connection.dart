import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

final wandFirebaseConnection =
    Provider<WANDFirebaseConnection>((ref) => WANDFirebaseConnection());

class WANDFirebaseConnection {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get store => _store;
}
