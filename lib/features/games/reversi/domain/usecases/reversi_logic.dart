import 'package:neo_game_suit/features/games/reversi/domain/entities/reversi_board.dart';

class ReversiLogic {
  static const directions = [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),          (0, 1),
    (1, -1),  (1, 0), (1, 1),
  ];

  static List<List<int>> getFlippedPieces(ReversiBoard board, int row, int col, Player player) {
    if (!board.isTileEmpty(row, col)) return [];

    final flipped = <List<int>>[];
    final opponent = player == Player.black ? Player.white : Player.black;

    for (final dir in directions) {
      final dr = dir.$1;
      final dc = dir.$2;
      final current = <List<int>>[];
      var r = row + dr;
      var c = col + dc;

      while (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board.getTile(r, c) == opponent) {
        current.add([r, c]);
        r += dr;
        c += dc;
      }

      if (current.isNotEmpty && r >= 0 && r < boardSize && c >= 0 && c < boardSize && board.getTile(r, c) == player) {
        flipped.addAll(current);
      }
    }

    return flipped;
  }

  static bool isValidMove(ReversiBoard board, int row, int col, Player player) {
    return getFlippedPieces(board, row, col, player).isNotEmpty;
  }

  static List<(int, int)> getValidMoves(ReversiBoard board, Player player) {
    final moves = <(int, int)>[];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (isValidMove(board, r, c, player)) {
          moves.add((r, c));
        }
      }
    }
    return moves;
  }

  static ReversiBoard makeMove(ReversiBoard board, int row, int col) {
    if (board.status != GameStatus.playing) return board;
    if (!isValidMove(board, row, col, board.currentPlayer)) return board;

    final newBoard = _deepCopyBoard(board.board);
    final flipped = getFlippedPieces(board, row, col, board.currentPlayer);

    // Place the new piece
    newBoard[row][col] = board.currentPlayer;

    // Flip the pieces
    for (final pos in flipped) {
      newBoard[pos[0]][pos[1]] = board.currentPlayer;
    }

    // Calculate scores
    var blackScore = 0;
    var whiteScore = 0;
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (newBoard[r][c] == Player.black) blackScore++;
        if (newBoard[r][c] == Player.white) whiteScore++;
      }
    }

    // Switch player or skip if no valid moves
    final nextPlayer = board.currentPlayer == Player.black ? Player.white : Player.black;
    final nextPlayerMoves = getValidMoves(
      ReversiBoard.initial(mode: board.mode).copyWith(board: newBoard, currentPlayer: nextPlayer),
      nextPlayer,
    );

    Player finalPlayer;
    GameStatus finalStatus;

    if (nextPlayerMoves.isNotEmpty) {
      finalPlayer = nextPlayer;
      finalStatus = GameStatus.playing;
    } else {
      // Check if current player has moves (double skip)
      final currentPlayerMoves = getValidMoves(
        ReversiBoard.initial(mode: board.mode).copyWith(board: newBoard, currentPlayer: board.currentPlayer),
        board.currentPlayer,
      );
      if (currentPlayerMoves.isNotEmpty) {
        finalPlayer = board.currentPlayer; // Current player gets another turn
        finalStatus = GameStatus.playing;
      } else {
        // Game over
        finalPlayer = board.currentPlayer;
        if (blackScore > whiteScore) {
          finalStatus = GameStatus.blackWon;
        } else if (whiteScore > blackScore) {
          finalStatus = GameStatus.whiteWon;
        } else {
          finalStatus = GameStatus.draw;
        }
      }
    }

    return ReversiBoard(
      board: newBoard,
      currentPlayer: finalPlayer,
      status: finalStatus,
      mode: board.mode,
      humanPlayer: board.humanPlayer,
      blackScore: blackScore,
      whiteScore: whiteScore,
      lastFlipped: flipped,
      lastMove: (row, col),
    );
  }

  static List<List<Player>> _deepCopyBoard(List<List<Player>> board) {
    return board.map((row) => List<Player>.from(row)).toList();
  }

  static ReversiBoard reset({GameMode mode = GameMode.hvh}) {
    return ReversiBoard.initial(mode: mode);
  }

  static ReversiBoard makeAiMove(ReversiBoard board) {
    if (board.status != GameStatus.playing) return board;

    final aiPlayer = board.humanPlayer == Player.black ? Player.white : Player.black;
    if (board.currentPlayer != aiPlayer) return board;

    final validMoves = getValidMoves(board, aiPlayer);
    if (validMoves.isEmpty) return board;

    // Simple heuristic: corners are best, then edges, then center with mobility
    (int, int)? bestMove;
    int bestScore = -1000;

    for (final move in validMoves) {
      final score = _evaluateMove(board, move, aiPlayer);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    if (bestMove != null) {
      return makeMove(board, bestMove.$1, bestMove.$2);
    }

    return board;
  }

  static int _evaluateMove(ReversiBoard board, (int, int) move, Player player) {
    var score = 0;
    final row = move.$1;
    final col = move.$2;

    // Corner bonus
    if ((row == 0 || row == 7) && (col == 0 || col == 7)) {
      score += 50;
    }
    // Edge bonus (but not adjacent to corners if corner is empty)
    else if (row == 0 || row == 7 || col == 0 || col == 7) {
      // Check if adjacent to empty corner
      var adjacentToEmptyCorner = false;
      if (row == 0 && col == 1 && board.getTile(0, 0) == Player.none) adjacentToEmptyCorner = true;
      if (row == 0 && col == 6 && board.getTile(0, 7) == Player.none) adjacentToEmptyCorner = true;
      if (row == 7 && col == 1 && board.getTile(7, 0) == Player.none) adjacentToEmptyCorner = true;
      if (row == 7 && col == 6 && board.getTile(7, 7) == Player.none) adjacentToEmptyCorner = true;
      if (row == 1 && col == 0 && board.getTile(0, 0) == Player.none) adjacentToEmptyCorner = true;
      if (row == 6 && col == 0 && board.getTile(7, 0) == Player.none) adjacentToEmptyCorner = true;
      if (row == 1 && col == 7 && board.getTile(0, 7) == Player.none) adjacentToEmptyCorner = true;
      if (row == 6 && col == 7 && board.getTile(7, 7) == Player.none) adjacentToEmptyCorner = true;

      if (adjacentToEmptyCorner) {
        score -= 20;
      } else {
        score += 10;
      }
    }
    // Avoid squares adjacent to corners if corner is empty
    else if ((row == 1 || row == 6) && (col == 1 || col == 6)) {
      score -= 25;
    }

    // Mobility: number of pieces flipped
    score += getFlippedPieces(board, row, col, player).length * 2;

    return score;
  }
}
