import 'dart:math';
import 'package:neo_game_suit/features/games/gomoku/domain/entities/gomoku_board.dart';

const winScore = 1000000;

class GomokuAI {
  static const patternScores = {
    'five': winScore,
    'liveFour': 10000,
    'deadFour': 1000,
    'liveThree': 1000,
    'deadThree': 100,
    'liveTwo': 100,
    'deadTwo': 10,
    'liveOne': 10,
    'deadOne': 1,
  };

  static int evaluateWindow(List<Player?> window, Player aiPlayer) {
    final opponent = aiPlayer == blackPlayer ? whitePlayer : blackPlayer;
    final playerCount = window.where((p) => p == aiPlayer).length;
    final opponentCount = window.where((p) => p == opponent).length;

    if (playerCount > 0 && opponentCount > 0) return 0;
    if (playerCount == 0 && opponentCount == 0) return 0;

    final count = playerCount > 0 ? playerCount : opponentCount;
    final isAI = playerCount > 0;

    switch (count) {
      case 5:
        return isAI ? patternScores['five']! : -patternScores['five']!;
      case 4:
        return isAI ? patternScores['liveFour']! : -patternScores['liveFour']!;
      case 3:
        return isAI ? patternScores['liveThree']! : -patternScores['liveThree']!;
      case 2:
        return isAI ? patternScores['liveTwo']! : -patternScores['liveTwo']!;
      case 1:
        return isAI ? patternScores['liveOne']! : -patternScores['liveOne']!;
      default:
        return 0;
    }
  }

  static int evaluateBoard(List<List<Player?>> board, Player aiPlayer) {
    int totalScore = 0;

    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (c <= boardSize - 5) {
          final window = [board[r][c], board[r][c+1], board[r][c+2], board[r][c+3], board[r][c+4]];
          totalScore += evaluateWindow(window, aiPlayer);
        }
        if (r <= boardSize - 5) {
          final window = [board[r][c], board[r+1][c], board[r+2][c], board[r+3][c], board[r+4][c]];
          totalScore += evaluateWindow(window, aiPlayer);
        }
        if (r <= boardSize - 5 && c <= boardSize - 5) {
          final window = [board[r][c], board[r+1][c+1], board[r+2][c+2], board[r+3][c+3], board[r+4][c+4]];
          totalScore += evaluateWindow(window, aiPlayer);
        }
        if (r >= 4 && c <= boardSize - 5) {
          final window = [board[r][c], board[r-1][c+1], board[r-2][c+2], board[r-3][c+3], board[r-4][c+4]];
          totalScore += evaluateWindow(window, aiPlayer);
        }
      }
    }
    return totalScore;
  }

  static List<List<int>> getPossibleMoves(List<List<Player?>> board) {
    final moves = <List<int>>[];
    const searchRadius = 2;

    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == null) {
          bool isNearPiece = false;
          for (int dr = -searchRadius; dr <= searchRadius; dr++) {
            for (int dc = -searchRadius; dc <= searchRadius; dc++) {
              if (dr == 0 && dc == 0) continue;
              final nr = r + dr;
              final nc = c + dc;
              if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize && board[nr][nc] != null) {
                isNearPiece = true;
                break;
              }
            }
            if (isNearPiece) break;
          }
          if (isNearPiece) {
            moves.add([r, c]);
          }
        }
      }
    }
    return moves.isNotEmpty ? moves : [[boardSize ~/ 2, boardSize ~/ 2]];
  }

  static List<List<Player?>> _copyBoard(List<List<Player?>> board) {
    return board.map((row) => List<Player?>.from(row)).toList();
  }

  static int minimax(List<List<Player?>> board, int depth, int alpha, int beta, bool isMaximizing, Player aiPlayer) {
    final score = evaluateBoard(board, aiPlayer);

    if (score.abs() >= winScore || depth == 0) {
      return score;
    }

    final possibleMoves = getPossibleMoves(board);
    final opponent = aiPlayer == blackPlayer ? whitePlayer : blackPlayer;

    if (isMaximizing) {
      int maxEval = -0x7ffffffff;
      for (final move in possibleMoves) {
        final r = move[0];
        final c = move[1];
        board[r][c] = aiPlayer;
        final evalScore = minimax(board, depth - 1, alpha, beta, false, aiPlayer);
        board[r][c] = null;
        maxEval = max(maxEval, evalScore);
        alpha = max(alpha, evalScore);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 0x7ffffffff;
      for (final move in possibleMoves) {
        final r = move[0];
        final c = move[1];
        board[r][c] = opponent;
        final evalScore = minimax(board, depth - 1, alpha, beta, true, aiPlayer);
        board[r][c] = null;
        minEval = min(minEval, evalScore);
        beta = min(beta, evalScore);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static List<int> findBestMove(GomokuBoard board, Player player) {
    final tempBoard = _copyBoard(board.board);
    int bestScore = -0x7ffffffff;
    List<int>? bestMove;
    final possibleMoves = getPossibleMoves(tempBoard);
    const searchDepth = 3;

    for (final move in possibleMoves) {
      final r = move[0];
      final c = move[1];
      tempBoard[r][c] = player;
      final moveScore = minimax(tempBoard, searchDepth - 1, -0x7ffffffff, 0x7ffffffff, false, player);
      tempBoard[r][c] = null;

      if (moveScore > bestScore) {
        bestScore = moveScore;
        bestMove = move;
      }
    }

    return bestMove ?? [boardSize ~/ 2, boardSize ~/ 2];
  }
}
