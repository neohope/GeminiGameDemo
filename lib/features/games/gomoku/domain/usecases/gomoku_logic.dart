import 'package:neo_game_suit/features/games/gomoku/domain/entities/gomoku_board.dart';

class GomokuLogic {
  static bool checkWin(GomokuBoard board, int row, int col, Player player) {
    const directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    for (final dir in directions) {
      int count = 1;
      for (int i = 1; i < 5; i++) {
        final r = row + dir[0] * i;
        final c = col + dir[1] * i;
        if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board.getCell(r, c) == player) {
          count++;
        } else {
          break;
        }
      }
      for (int i = 1; i < 5; i++) {
        final r = row - dir[0] * i;
        final c = col - dir[1] * i;
        if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board.getCell(r, c) == player) {
          count++;
        } else {
          break;
        }
      }
      if (count >= 5) return true;
    }
    return false;
  }

  static bool isValidMove(GomokuBoard board, int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize && board.getCell(row, col) == null;
  }
}
