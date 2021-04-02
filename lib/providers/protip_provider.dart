import 'package:flutter_riverpod/flutter_riverpod.dart';

class Protip {
  Protip([this.id, this.text]);
  int id;
  String text;
}

final protipProvider = Provider((ref) => [
      Protip(0,
          "You can win by getting 3 of your marks in a row (up, down, across, or diagonally)."),
      Protip(1, "TEST2TEST2TEST2TEST2TEST2TEST2TEST2TEST2TEST2TEST2TEST2"),
      Protip(2, "TEST3TEST3TEST3TEST3TEST3TEST3TEST3TEST3TEST3"),
      Protip(3, "TEST4TEST4TEST4TEST4TEST4"),
    ]);
