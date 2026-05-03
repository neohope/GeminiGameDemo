import 'package:neo_game_suit/features/games/tetris/domain/entities/tetris_board.dart';

class TetrisLogic {
  static TetrisBoard moveLeft(TetrisBoard board) {
    final newPiece = board.currentPiece.copyWith(x: board.currentPiece.x - 1);
    if (_isValidPosition(board.board, newPiece)) {
      return board.copyWith(currentPiece: newPiece);
    }
    return board;
  }

  static TetrisBoard moveRight(TetrisBoard board) {
    final newPiece = board.currentPiece.copyWith(x: board.currentPiece.x + 1);
    if (_isValidPosition(board.board, newPiece)) {
      return board.copyWith(currentPiece: newPiece);
    }
    return board;
  }

  static TetrisBoard moveDown(TetrisBoard board) {
    final newPiece = board.currentPiece.copyWith(y: board.currentPiece.y + 1);
    if (_isValidPosition(board.board, newPiece)) {
      return board.copyWith(currentPiece: newPiece);
    }
    // Can't move down, lock the piece and clear lines
    return _lockPiece(board);
  }

  static TetrisBoard hardDrop(TetrisBoard board) {
    var current = board;
    while (true) {
      final newPiece = current.currentPiece.copyWith(y: current.currentPiece.y + 1);
      if (!_isValidPosition(current.board, newPiece)) {
        break;
      }
      current = moveDown(current);
    }
    return _lockPiece(current);
  }

  static TetrisBoard rotate(TetrisBoard board) {
    final newPiece = board.currentPiece.copyWith(rotation: board.currentPiece.rotation + 1);
    if (_isValidPosition(board.board, newPiece)) {
      return board.copyWith(currentPiece: newPiece);
    }
    // Wall kick - try moving left or right if rotation is invalid
    for (int offset in [1, -1, 2, -2]) {
      final kicked = newPiece.copyWith(x: newPiece.x + offset);
      if (_isValidPosition(board.board, kicked)) {
        return board.copyWith(currentPiece: kicked);
      }
    }
    return board;
  }

  static bool _isValidPosition(List<List<PieceType?>> board, Piece piece) {
    final shape = piece.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          final boardX = piece.x + x;
          final boardY = piece.y + y;
          // Out of bounds
          if (boardX < 0 || boardX >= TetrisBoard.cols || boardY >= TetrisBoard.rows) {
            return false;
          }
          // Collides with existing pieces (only check if above board)
          if (boardY >= 0 && board[boardY][boardX] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static TetrisBoard _lockPiece(TetrisBoard board) {
    final newBoard = TetrisBoard.deepCopyBoard(board.board);
    final shape = board.currentPiece.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          final boardX = board.currentPiece.x + x;
          final boardY = board.currentPiece.y + y;
          if (boardY >= 0 && boardY < TetrisBoard.rows && boardX >= 0 && boardX < TetrisBoard.cols) {
            newBoard[boardY][boardX] = board.currentPiece.type;
          }
        }
      }
    }

    // Clear lines and calculate score
    final clearedBoard = _clearLines(newBoard);
    final linesCleared = clearedBoard.$2;
    final newLinesCleared = board.linesCleared + linesCleared;
    final newScore = board.score + _calculateScore(linesCleared, board.level);
    final newLevel = 1 + (newLinesCleared / 10).floor();
    final newHighScore = newScore > board.highScore ? newScore : board.highScore;

    // Check for game over
    final nextPiece = board.nextPiece;
    if (!_isValidPosition(clearedBoard.$1, nextPiece)) {
      return board.copyWith(
        board: clearedBoard.$1,
        score: newScore,
        highScore: newHighScore,
        linesCleared: newLinesCleared,
        level: newLevel,
        status: GameStatus.gameOver,
      );
    }

    return board.copyWith(
      board: clearedBoard.$1,
      currentPiece: nextPiece,
      nextPiece: TetrisBoard.createRandomPiece(),
      score: newScore,
      highScore: newHighScore,
      linesCleared: newLinesCleared,
      level: newLevel,
    );
  }

  static (List<List<PieceType?>>, int) _clearLines(List<List<PieceType?>> board) {
    final newBoard = <List<PieceType?>>[];
    int linesCleared = 0;

    for (int y = 0; y < TetrisBoard.rows; y++) {
      final line = board[y];
      final isFull = line.every((cell) => cell != null);
      if (isFull) {
        linesCleared++;
      } else {
        newBoard.add(List<PieceType?>.from(line));
      }
    }

    // Add empty lines at the top
    for (int i = 0; i < linesCleared; i++) {
      newBoard.insert(0, List<PieceType?>.filled(TetrisBoard.cols, null));
    }

    return (newBoard, linesCleared);
  }

  static int _calculateScore(int lines, int level) {
    const lineScores = [0, 100, 300, 500, 800];
    return lineScores[lines] * level;
  }

  static TetrisBoard startGame(TetrisBoard board) {
    return board.copyWith(status: GameStatus.playing);
  }

  static TetrisBoard reset(DifficultySettings settings) {
    return TetrisBoard.initial(settings);
  }

  static TetrisBoard togglePause(TetrisBoard board) {
    if (board.status == GameStatus.playing) {
      return board.copyWith(status: GameStatus.paused);
    } else if (board.status == GameStatus.paused) {
      return board.copyWith(status: GameStatus.playing);
    }
    return board;
  }
}
