import 'package:flutter/material.dart';

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
        child: Text(
          "${widget.gameId}",
        ),
      ),
    );
  }
}
