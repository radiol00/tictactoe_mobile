class GameState {
  String id;
  List<List<int>> board;
  String player = "X";
  String enemy = "O";

  // 0 - CLEAN FIELD
  // 1 - O
  // 2 - X

  GameState() {
    board = [
      [0, 0, 0],
      [0, 0, 0],
      [0, 0, 0],
    ];
  }
}
