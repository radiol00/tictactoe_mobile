import 'package:flutter/material.dart';
import 'package:wand_tictactoe/enums/enums.dart';

class GameResult {
  Figure figure;
  Alignment start;
  Alignment end;
  bool draw;
  GameResult({this.start, this.end, this.figure}) {
    draw = false;
  }
}
