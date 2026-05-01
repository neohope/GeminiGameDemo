import 'dart:math';
import 'package:neo_game_suit/features/games/sudoku/domain/entities/sudoku_board.dart';

class SudokuLogic {
  static SudokuBoard generateBoard() {
    final board = List<int?>.filled(81, null);
    _solveSudoku(board);
    final initialBoard = List<int?>.from(board);
    _removeNumbers(initialBoard, 40);
    return SudokuBoard(
      board: List<int?>.from(initialBoard),
      initialBoard: initialBoard,
    );
  }

  static bool _solveSudoku(List<int?> board) {
    final empty = _findEmpty(board);
    if (empty == null) return true;

    final row = empty[0];
    final col = empty[1];
    final numbers = List.generate(9, (i) => i + 1)..shuffle();

    for (final num in numbers) {
      if (_isValid(board, num, [row, col])) {
        board[row * 9 + col] = num;
        if (_solveSudoku(board)) return true;
        board[row * 9 + col] = null;
      }
    }
    return false;
  }

  static List<int>? _findEmpty(List<int?> board) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i * 9 + j] == null) {
          return [i, j];
        }
      }
    }
    return null;
  }

  static bool _isValid(List<int?> board, int num, List<int> pos) {
    final row = pos[0];
    final col = pos[1];

    for (int i = 0; i < 9; i++) {
      if (board[row * 9 + i] == num && col != i) return false;
    }

    for (int i = 0; i < 9; i++) {
      if (board[i * 9 + col] == num && row != i) return false;
    }

    final boxX = (col / 3).floor() * 3;
    final boxY = (row / 3).floor() * 3;

    for (int i = boxY; i < boxY + 3; i++) {
      for (int j = boxX; j < boxX + 3; j++) {
        if (board[i * 9 + j] == num && (i != row || j != col)) return false;
      }
    }

    return true;
  }

  static void _removeNumbers(List<int?> board, int count) {
    final random = Random();
    int removed = 0;
    while (removed < count) {
      final index = random.nextInt(81);
      if (board[index] != null) {
        board[index] = null;
        removed++;
      }
    }
  }

  static bool solveSudoku(SudokuBoard board) {
    final tempBoard = List<int?>.from(board.initialBoard);
    if (_solveSudoku(tempBoard)) {
      for (int i = 0; i < 81; i++) {
        board.board[i] = tempBoard[i];
      }
      return true;
    }
    return false;
  }

  static Set<int> findConflicts(SudokuBoard board) {
    final conflicts = <int>{};

    for (int row = 0; row < 9; row++) {
      final seen = <int, List<int>>{};
      for (int col = 0; col < 9; col++) {
        final num = board.getCell(row, col);
        if (num != null) {
          final idx = row * 9 + col;
          if (!seen.containsKey(num)) seen[num] = [];
          seen[num]!.add(idx);
        }
      }
      for (final indices in seen.values) {
        if (indices.length > 1) conflicts.addAll(indices);
      }
    }

    for (int col = 0; col < 9; col++) {
      final seen = <int, List<int>>{};
      for (int row = 0; row < 9; row++) {
        final num = board.getCell(row, col);
        if (num != null) {
          final idx = row * 9 + col;
          if (!seen.containsKey(num)) seen[num] = [];
          seen[num]!.add(idx);
        }
      }
      for (final indices in seen.values) {
        if (indices.length > 1) conflicts.addAll(indices);
      }
    }

    for (int box = 0; box < 9; box++) {
      final boxRow = (box / 3).floor() * 3;
      final boxCol = (box % 3) * 3;
      final seen = <int, List<int>>{};
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final row = boxRow + i;
          final col = boxCol + j;
          final num = board.getCell(row, col);
          if (num != null) {
            final idx = row * 9 + col;
            if (!seen.containsKey(num)) seen[num] = [];
            seen[num]!.add(idx);
          }
        }
      }
      for (final indices in seen.values) {
        if (indices.length > 1) conflicts.addAll(indices);
      }
    }

    return conflicts;
  }

  static bool isComplete(SudokuBoard board) {
    return !board.board.contains(null);
  }

  static bool isSolved(SudokuBoard board) {
    return isComplete(board) && findConflicts(board).isEmpty;
  }
}
