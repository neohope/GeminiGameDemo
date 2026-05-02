import 'dart:math';
import 'package:neo_game_suit/features/games/game2048/domain/entities/game2048_board.dart';

const int _boardSize = 4;

enum MoveDirection {
  up,
  down,
  left,
  right,
}

class Game2048Logic {
  static Game2048Board move(Game2048Board board, MoveDirection direction) {
    if (board.gameOver) return board;

    final newBoard = _copyBoard(board.board);
    int newScore = board.score;
    bool moved = false;

    switch (direction) {
      case MoveDirection.left:
        for (int i = 0; i < _boardSize; i++) {
          final result = _slideAndMergeRow(newBoard[i]);
          newBoard[i] = result.row;
          newScore += result.score;
          moved = moved || result.moved;
        }
        break;
      case MoveDirection.right:
        for (int i = 0; i < _boardSize; i++) {
          final reversed = newBoard[i].reversed.toList();
          final result = _slideAndMergeRow(reversed);
          newBoard[i] = result.row.reversed.toList();
          newScore += result.score;
          moved = moved || result.moved;
        }
        break;
      case MoveDirection.up:
        for (int j = 0; j < _boardSize; j++) {
          final col = _getCol(newBoard, j);
          final result = _slideAndMergeRow(col);
          _setCol(newBoard, j, result.row);
          newScore += result.score;
          moved = moved || result.moved;
        }
        break;
      case MoveDirection.down:
        for (int j = 0; j < _boardSize; j++) {
          final col = _getCol(newBoard, j).reversed.toList();
          final result = _slideAndMergeRow(col);
          _setCol(newBoard, j, result.row.reversed.toList());
          newScore += result.score;
          moved = moved || result.moved;
        }
        break;
    }

    if (!moved) return board;

    final boardWithNewTile = _addRandomTile(newBoard);
    final isWin = board.isWin || _has2048(boardWithNewTile);
    final gameOver = _isGameOver(boardWithNewTile);
    final bestScore = max(board.bestScore, newScore);

    return Game2048Board(
      board: boardWithNewTile,
      score: newScore,
      bestScore: bestScore,
      gameOver: gameOver,
      isWin: isWin,
    );
  }

  static List<List<int>> _addRandomTile(List<List<int>> board) {
    final emptyTiles = <Point>[];
    for (int i = 0; i < _boardSize; i++) {
      for (int j = 0; j < _boardSize; j++) {
        if (board[i][j] == 0) {
          emptyTiles.add(Point(i, j));
        }
      }
    }
    if (emptyTiles.isEmpty) return board;

    final random = Random();
    final tile = emptyTiles[random.nextInt(emptyTiles.length)];
    final value = random.nextDouble() < 0.9 ? 2 : 4;
    final newBoard = _copyBoard(board);
    newBoard[tile.x][tile.y] = value;
    return newBoard;
  }

  static List<List<int>> _copyBoard(List<List<int>> board) {
    return board.map((row) => List<int>.from(row)).toList();
  }

  static Game2048Board addInitialTiles(Game2048Board board) {
    final newBoard = _addRandomTile(_addRandomTile(board.board));
    return Game2048Board(board: newBoard);
  }

  static _SlideResult _slideAndMergeRow(List<int> row) {
    final filtered = row.where((tile) => tile != 0).toList();
    final newRow = <int>[];
    int score = 0;
    bool moved = false;

    for (int i = 0; i < filtered.length; i++) {
      if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
        final merged = filtered[i] * 2;
        newRow.add(merged);
        score += merged;
        i++;
      } else {
        newRow.add(filtered[i]);
      }
    }

    while (newRow.length < _boardSize) {
      newRow.add(0);
    }

    moved = !_rowsEqual(row, newRow);

    return _SlideResult(row: newRow, score: score, moved: moved);
  }

  static bool _rowsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static List<int> _getCol(List<List<int>> board, int col) {
    return List.generate(_boardSize, (i) => board[i][col]);
  }

  static void _setCol(List<List<int>> board, int col, List<int> newCol) {
    for (int i = 0; i < _boardSize; i++) {
      board[i][col] = newCol[i];
    }
  }

  static bool _has2048(List<List<int>> board) {
    for (int i = 0; i < _boardSize; i++) {
      for (int j = 0; j < _boardSize; j++) {
        if (board[i][j] == 2048) return true;
      }
    }
    return false;
  }

  static bool _isGameOver(List<List<int>> board) {
    for (int i = 0; i < _boardSize; i++) {
      for (int j = 0; j < _boardSize; j++) {
        if (board[i][j] == 0) return false;
        if (j + 1 < _boardSize && board[i][j] == board[i][j + 1]) return false;
        if (i + 1 < _boardSize && board[i][j] == board[i + 1][j]) return false;
      }
    }
    return true;
  }
}

class _SlideResult {
  final List<int> row;
  final int score;
  final bool moved;

  _SlideResult({required this.row, required this.score, required this.moved});
}

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);
}
