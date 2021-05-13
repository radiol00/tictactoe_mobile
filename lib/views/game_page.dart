import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/game_controller_provider.dart';

class GamePage extends StatefulWidget {
  GamePage({this.gameId});
  final String gameId;
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read(gameController).leaveGame();
          },
          child: Text('Leave game'),
        ),
      ),
    );
  }
}
