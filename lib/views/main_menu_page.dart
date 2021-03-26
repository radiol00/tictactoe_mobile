import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';

class MainMenuPage extends StatefulWidget {
  MainMenuPage({this.runInitAnimations});
  final bool runInitAnimations;
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read(firebaseAuthController).logout();
        },
        child: Text("logout"),
      ),
    );
  }
}
