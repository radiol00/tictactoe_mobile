import 'package:flutter/material.dart';
import 'package:wand_tictactoe/models/game_result.dart';

class GameResultPainter extends CustomPainter {
  GameResult _result;
  Paint resultPaint;
  GameResultPainter(GameResult result) {
    _result = result;
    resultPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 10;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = _result.start.alongSize(size);
    final p2 = _result.end.alongSize(size);

    canvas.drawLine(p1, p2, resultPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
