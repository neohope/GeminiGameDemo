import 'dart:math';
import 'package:neo_game_suit/features/games/tictactoe/domain/entities/tictactoe_board.dart';

class TicTacToeLogic {
  static List<List<Player>> _deepCopyBoard(List<List<Player>> board) {
    return board.map((row) => List<Player>.from(row)).toList();
  }

  static TicTacToeBoard makeMove(TicTacToeBoard board, int row, int col) {
    if (board.status != GameStatus.playing || !board.isTileEmpty(row, col)) {
      return board;
    }

    final newBoard = _deepCopyBoard(board.board);
    newBoard[row][col] = board.currentPlayer;

    final result = _checkGameStatus(newBoard);
    final nextPlayer = board.currentPlayer == Player.x ? Player.o : Player.x;

    return TicTacToeBoard(
      board: newBoard,
      currentPlayer: nextPlayer,
      status: result.$1,
      mode: board.mode,
      humanPlayer: board.humanPlayer,
      winningLine: result.$2,
    );
  }

  static (GameStatus, List<List<int>>?) _checkGameStatus(List<List<Player>> board) {
    // Check rows
    for (int row = 0; row < boardSize; row++) {
      if (board[row][0] != Player.none &&
          board[row][0] == board[row][1] &&
          board[row][0] == board[row][2]) {
        final status = board[row][0] == Player.x ? GameStatus.xWon : GameStatus.oWon;
        return (status, [
          [row, 0],
          [row, 1],
          [row, 2]
        ]);
      }
    }

    // Check columns
    for (int col = 0; col < boardSize; col++) {
      if (board[0][col] != Player.none &&
          board[0][col] == board[1][col] &&
          board[0][col] == board[2][col]) {
        final status = board[0][col] == Player.x ? GameStatus.xWon : GameStatus.oWon;
        return (status, [
          [0, col],
          [1, col],
          [2, col]
        ]);
      }
    }

    // Check diagonals
    if (board[0][0] != Player.none &&
        board[0][0] == board[1][1] &&
        board[0][0] == board[2][2]) {
      final status = board[0][0] == Player.x ? GameStatus.xWon : GameStatus.oWon;
      return (status, [
        [0, 0],
        [1, 1],
        [2, 2]
      ]);
    }
    if (board[0][2] != Player.none &&
        board[0][2] == board[1][1] &&
        board[0][2] == board[2][0]) {
      final status = board[0][2] == Player.x ? GameStatus.xWon : GameStatus.oWon;
      return (status, [
        [0, 2],
        [1, 1],
        [2, 0]
      ]);
    }

    // Check draw
    final isFull = board.every((row) => row.every((cell) => cell != Player.none));
    if (isFull) {
      return (GameStatus.draw, null);
    }

    return (GameStatus.playing, null);
  }

  static TicTacToeBoard reset({GameMode mode = GameMode.hvh}) {
    return TicTacToeBoard.initial(mode: mode);
  }

  static TicTacToeBoard makeAiMove(TicTacToeBoard board) {
    if (board.status != GameStatus.playing) return board;

    final aiPlayer = board.humanPlayer == Player.x ? Player.o : Player.x;
    if (board.currentPlayer != aiPlayer) return board;

    // Try to win
    final winningMove = _findWinningMove(board, aiPlayer);
    if (winningMove != null) {
      return makeMove(board, winningMove.$1, winningMove.$2);
    }

    // Block opponent from winning
    final humanPlayer = board.humanPlayer;
    final blockingMove = _findWinningMove(board, humanPlayer);
    if (blockingMove != null) {
      return makeMove(board, blockingMove.$1, blockingMove.$2);
    }

    // Take center if available
    if (board.isTileEmpty(1, 1)) {
      return makeMove(board, 1, 1);
    }

    // Take a corner
    final corners = [
      (0, 0),
      (0, 2),
      (2, 0),
      (2, 2)
    ];
    final emptyCorners = corners.where((c) => board.isTileEmpty(c.$1, c.$2)).toList();
    if (emptyCorners.isNotEmpty) {
      final random = Random();
      final corner = emptyCorners[random.nextInt(emptyCorners.length)];
      return makeMove(board, corner.$1, corner.$2);
    }

    // Take any empty space
    final emptySpaces = <(int, int)>[];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board.isTileEmpty(i, j)) {
          emptySpaces.add((i, j));
        }
      }
    }
    if (emptySpaces.isNotEmpty) {
      final random = Random();
      final space = emptySpaces[random.nextInt(emptySpaces.length)];
      return makeMove(board, space.$1, space.$2);
    }

    return board;
  }

  static (int, int)? _findWinningMove(TicTacToeBoard board, Player player) {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board.isTileEmpty(i, j)) {
          final testBoard = _deepCopyBoard(board.board);
          testBoard[i][j] = player;
          final result = _checkGameStatus(testBoard);
          if (result.$1 == (player == Player.x ? GameStatus.xWon : GameStatus.oWon)) {
            return (i, j);
          }
        }
      }
    }
    return null;
  }
}
