import 'package:neo_game_suit/features/games/chess/domain/entities/chess_board.dart';

class ChessLogic {
  static bool isValidMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board.getPiece(fromRow, fromCol);
    if (piece == null) return false;
    if (piece.color != board.currentPlayer) return false;

    final target = board.getPiece(toRow, toCol);
    if (target != null && target.color == piece.color) return false;

    switch (piece.type) {
      case pawn: return _isValidPawnMove(board, piece.color, fromRow, fromCol, toRow, toCol);
      case rook: return _isValidRookMove(board, fromRow, fromCol, toRow, toCol);
      case knight: return _isValidKnightMove(fromRow, fromCol, toRow, toCol);
      case bishop: return _isValidBishopMove(board, fromRow, fromCol, toRow, toCol);
      case queen: return _isValidQueenMove(board, fromRow, fromCol, toRow, toCol);
      case king: return _isValidKingMove(fromRow, fromCol, toRow, toCol);
      default: return false;
    }
  }

  static bool _isValidPawnMove(ChessBoard board, Player color, int fromRow, int fromCol, int toRow, int toCol) {
    final direction = color == whitePlayer ? -1 : 1;
    final startRow = color == whitePlayer ? 6 : 1;
    final dx = toCol - fromCol;
    final dy = toRow - fromRow;

    if (dx == 0 && dy == direction) {
      return board.getPiece(toRow, toCol) == null;
    }

    if (dx == 0 && dy == 2 * direction && fromRow == startRow) {
      return board.getPiece(toRow, toCol) == null &&
             board.getPiece(fromRow + direction, fromCol) == null;
    }

    if (dx.abs() == 1 && dy == direction) {
      final target = board.getPiece(toRow, toCol);
      return target != null && target.color != color;
    }

    return false;
  }

  static bool _isValidRookMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    if (fromRow != toRow && fromCol != toCol) return false;
    return _isPathClear(board, fromRow, fromCol, toRow, toCol);
  }

  static bool _isValidKnightMove(int fromRow, int fromCol, int toRow, int toCol) {
    final dx = (toCol - fromCol).abs();
    final dy = (toRow - fromRow).abs();
    return (dx == 2 && dy == 1) || (dx == 1 && dy == 2);
  }

  static bool _isValidBishopMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    if ((toRow - fromRow).abs() != (toCol - fromCol).abs()) return false;
    return _isPathClear(board, fromRow, fromCol, toRow, toCol);
  }

  static bool _isValidQueenMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    return _isValidRookMove(board, fromRow, fromCol, toRow, toCol) ||
           _isValidBishopMove(board, fromRow, fromCol, toRow, toCol);
  }

  static bool _isValidKingMove(int fromRow, int fromCol, int toRow, int toCol) {
    final dx = (toCol - fromCol).abs();
    final dy = (toRow - fromRow).abs();
    return dx <= 1 && dy <= 1;
  }

  static bool _isPathClear(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final dx = (toCol - fromCol).sign;
    final dy = (toRow - fromRow).sign;
    int row = fromRow + dy;
    int col = fromCol + dx;
    while (row != toRow || col != toCol) {
      if (board.getPiece(row, col) != null) return false;
      row += dy;
      col += dx;
    }
    return true;
  }

  static ChessBoard makeMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final newBoard = _copyBoard(board.board);
    newBoard[toRow][toCol] = newBoard[fromRow][fromCol];
    newBoard[fromRow][fromCol] = null;
    final nextPlayer = board.currentPlayer == whitePlayer ? blackPlayer : whitePlayer;
    return ChessBoard(board: newBoard, currentPlayer: nextPlayer);
  }

  static List<List<Piece?>> _copyBoard(List<List<Piece?>> board) {
    return board.map((row) => List<Piece?>.from(row)).toList();
  }
}
