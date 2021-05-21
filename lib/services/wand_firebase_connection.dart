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

  DocumentReference getGameDoc(String gameId) {
    CollectionReference gameCollection = _store.collection("games");
    DocumentReference gameDoc = gameCollection.doc(gameId);
    return gameDoc;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPlayerDoc(
      String userId) async {
    var doc = await _store.collection("users").doc(userId).get().then((value) {
      if (value.exists)
        return value;
      else
        throw FirebaseException(plugin: "firestore");
    });

    return doc;
  }
}
