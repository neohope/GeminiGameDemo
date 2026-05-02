import 'dart:math';
import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/usecases/chinese_chess_logic.dart';

class ChineseChessAI {
  static const Map<String, int> pieceValues = {
    '帥': 10000,
    '將': 10000,
    '仕': 100,
    '士': 100,
    '相': 100,
    '象': 100,
    '馬': 400,
    '車': 1000,
    '炮': 450,
    '砲': 450,
    '兵': 50,
    '卒': 50,
  };

  static List<int> findBestMove(ChineseChessBoard board, Player aiPlayer) {
    final allMoves = <List<int>>[];

    for (final piece in board.pieces) {
      if (piece.color != aiPlayer) continue;

      for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 9; x++) {
          if (ChineseChessLogic.isValidMove(board, piece, x, y)) {
            allMoves.add([piece.x, piece.y, x, y]);
          }
        }
      }
    }

    if (allMoves.isEmpty) return [];

    int bestScore = -1000000;
    List<int>? bestMove;
    final random = Random();

    for (final move in allMoves) {
      final score = _evaluateMove(board, move, aiPlayer);
      final randomBonus = random.nextInt(20);

      if (score + randomBonus > bestScore) {
        bestScore = score + randomBonus;
        bestMove = move;
      }
    }

    return bestMove ?? allMoves.first;
  }

  static int _evaluateMove(ChineseChessBoard board, List<int> move, Player aiPlayer) {
    int score = 0;
    final fromX = move[0];
    final fromY = move[1];
    final toX = move[2];
    final toY = move[3];

    final target = board.getPieceAt(toX, toY);
    if (target != null) {
      score += pieceValues[target.text] ?? 0;
    }

    final movingPiece = board.getPieceAt(fromX, fromY);
    if (movingPiece != null) {
      if (movingPiece.text == '帥' || movingPiece.text == '將') {
        score -= 100;
      } else if (movingPiece.text == '兵' || movingPiece.text == '卒') {
        if (aiPlayer == redPlayer) {
          score += (fromY - toY) * 10;
        } else {
          score += (toY - fromY) * 10;
        }
      }
    }

    if (aiPlayer == blackPlayer) {
      score += (toY - fromY);
    } else {
      score += (fromY - toY);
    }

    final centerDistX = (toX - 4).abs();
    final centerDistY = (toY - 4.5).abs();
    score -= (centerDistX + centerDistY).toInt();

    return score;
  }
}
