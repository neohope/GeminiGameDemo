import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';

class ChineseChessLogic {
  static bool isValidMove(ChineseChessBoard board, Piece piece, int toX, int toY) {
    final target = board.getPieceAt(toX, toY);
    if (target != null && target.color == piece.color) return false;

    final dx = (piece.x - toX).abs();
    final dy = (piece.y - toY).abs();

    switch (piece.text) {
      case '車':
        if (piece.x != toX && piece.y != toY) return false;
        return _isPathClear(board, piece.x, piece.y, toX, toY);

      case '馬':
        if (!((dx == 1 && dy == 2) || (dx == 2 && dy == 1))) return false;
        if (dx == 1) {
          final checkY = piece.y + (toY > piece.y ? 1 : -1);
          if (board.getPieceAt(piece.x, checkY) != null) return false;
        } else {
          final checkX = piece.x + (toX > piece.x ? 1 : -1);
          if (board.getPieceAt(checkX, piece.y) != null) return false;
        }
        return true;

      case '相':
      case '象':
        if (dx != 2 || dy != 2) return false;
        if (piece.color == redPlayer && toY > 4) return false;
        if (piece.color == blackPlayer && toY < 5) return false;
        final eyeX = piece.x + (toX > piece.x ? 1 : -1);
        final eyeY = piece.y + (toY > piece.y ? 1 : -1);
        if (board.getPieceAt(eyeX, eyeY) != null) return false;
        return true;

      case '仕':
      case '士':
        if (dx != 1 || dy != 1) return false;
        if (toX < 3 || toX > 5) return false;
        if (piece.color == redPlayer && toY > 2) return false;
        if (piece.color == blackPlayer && toY < 7) return false;
        return true;

      case '帥':
      case '將':
        if (dx > 1 || dy > 1 || (dx == 0 && dy == 0)) return false;
        if (toX < 3 || toX > 5) return false;
        if (piece.color == redPlayer && toY > 2) return false;
        if (piece.color == blackPlayer && toY < 7) return false;
        return true;

      case '炮':
      case '砲':
        if (piece.x != toX && piece.y != toY) return false;
        final count = _countPathPieces(board, piece.x, piece.y, toX, toY);
        if (target != null && count == 1) return true;
        if (target == null && count == 0) return true;
        return false;

      case '兵':
        if (dy > 1 || dx > 1 || (dx == 1 && dy == 1)) return false;
        if (piece.y < 5 && toY < piece.y) return false;
        if (toY == piece.y && dx != 0 && piece.y < 5) return false;
        return true;

      case '卒':
        if (dy > 1 || dx > 1 || (dx == 1 && dy == 1)) return false;
        if (piece.y > 4 && toY > piece.y) return false;
        if (toY == piece.y && dx != 0 && piece.y > 4) return false;
        return true;

      default:
        return false;
    }
  }

  static bool _isPathClear(ChineseChessBoard board, int x1, int y1, int x2, int y2) {
    return _countPathPieces(board, x1, y1, x2, y2) == 0;
  }

  static int _countPathPieces(ChineseChessBoard board, int x1, int y1, int x2, int y2) {
    int count = 0;
    if (x1 == x2) {
      final start = y1 < y2 ? y1 : y2;
      final end = y1 > y2 ? y1 : y2;
      for (int y = start + 1; y < end; y++) {
        if (board.getPieceAt(x1, y) != null) count++;
      }
    } else {
      final start = x1 < x2 ? x1 : x2;
      final end = x1 > x2 ? x1 : x2;
      for (int x = start + 1; x < end; x++) {
        if (board.getPieceAt(x, y1) != null) count++;
      }
    }
    return count;
  }

  static ChineseChessBoard makeMove(ChineseChessBoard board, Piece piece, int toX, int toY) {
    final newPieces = board.pieces.where((p) => !(p.x == toX && p.y == toY)).toList();
    newPieces.removeWhere((p) => p.id == piece.id);
    newPieces.add(piece.copyWith(x: toX, y: toY));
    final nextPlayer = board.currentPlayer == redPlayer ? blackPlayer : redPlayer;
    return ChineseChessBoard(pieces: newPieces, currentPlayer: nextPlayer);
  }
}
