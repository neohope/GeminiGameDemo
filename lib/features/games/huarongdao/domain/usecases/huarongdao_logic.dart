import 'package:neo_game_suit/features/games/huarongdao/domain/entities/huarongdao_board.dart';

const boardWidth = 4;
const boardHeight = 5;

class HuarongdaoLogic {
  static bool isValidPosition(HuarongdaoBoard board, Piece piece, List<Piece> pieces) {
    // Check board boundaries
    if (piece.col < 0 ||
        piece.col + piece.width > boardWidth ||
        piece.row < 0 ||
        piece.row + piece.height > boardHeight) {
      return false;
    }

    // Check collisions with other pieces
    for (final other in pieces) {
      if (other.id == piece.id) continue;
      if (piecesOverlap(piece, other)) {
        return false;
      }
    }

    return true;
  }

  static bool piecesOverlap(Piece a, Piece b) {
    final aLeft = a.col;
    final aRight = a.col + a.width;
    final aTop = a.row;
    final aBottom = a.row + a.height;

    final bLeft = b.col;
    final bRight = b.col + b.width;
    final bTop = b.row;
    final bBottom = b.row + b.height;

    return !(aRight <= bLeft || aLeft >= bRight || aBottom <= bTop || aTop >= bBottom);
  }

  static HuarongdaoBoard movePiece(HuarongdaoBoard board, Piece piece, int dRow, int dCol) {
    final newPieces = board.pieces.map((p) => p.copyWith()).toList();
    final index = newPieces.indexWhere((p) => p.id == piece.id);
    if (index == -1) return board;

    final movedPiece = newPieces[index].copyWith(
      row: newPieces[index].row + dRow,
      col: newPieces[index].col + dCol,
    );

    // Create a list without the original piece to check collisions
    final otherPieces = newPieces.where((p) => p.id != piece.id).toList();
    if (!isValidPosition(board, movedPiece, otherPieces)) {
      return board;
    }

    newPieces[index] = movedPiece;

    // Check win condition: Caocao at bottom center
    final caocao = newPieces.firstWhere((p) => p.type == PieceType.caocao);
    final isWon = caocao.row == 3 && caocao.col == 1;

    return HuarongdaoBoard(
      pieces: newPieces,
      isWon: isWon,
      moveCount: board.moveCount + 1,
      levelId: board.levelId,
    );
  }

  static HuarongdaoBoard reset(HuarongdaoLevel level) {
    return HuarongdaoBoard.initial(level);
  }
}
