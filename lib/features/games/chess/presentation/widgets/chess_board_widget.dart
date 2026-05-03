import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/chess/domain/entities/chess_board.dart';

typedef CellTapCallback = void Function(int row, int col);

class ChessBoardWidget extends StatelessWidget {
  final ChessBoard board;
  final (int, int)? selectedPiece;
  final CellTapCallback onCellTap;

  const ChessBoardWidget({
    super.key,
    required this.board,
    required this.selectedPiece,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 700);
    final cellSize = boardSize / 8;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                _buildGrid(boardSize, cellSize),
                _buildPieces(cellSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(double boardSize, double cellSize) {
    return CustomPaint(
      size: Size(boardSize, boardSize),
      child: SizedBox.expand(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final isLight = (row + col) % 2 == 0;
            final isSelected = selectedPiece != null &&
                selectedPiece!.$1 == row && selectedPiece!.$2 == col;

            return GestureDetector(
              onTap: () => onCellTap(row, col),
              child: Container(
                color: isSelected
                    ? Colors.blue[300]
                    : (isLight ? const Color(0xFFF0D9B5) : const Color(0xFFB58863)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPieces(double cellSize) {
    final pieces = <Widget>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.getPiece(r, c);
        if (piece != null) {
          final unicode = _getUnicode(piece.type, piece.color);
          final isWhite = piece.color == whitePlayer;
          final offset = _getPieceOffset(piece.type, piece.color);
          pieces.add(Positioned(
            left: c * cellSize,
            top: r * cellSize,
            child: IgnorePointer(
              child: SizedBox(
                width: cellSize,
                height: cellSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: offset.dx,
                      top: offset.dy,
                      right: -offset.dx,
                      bottom: -offset.dy,
                      child: Center(
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            isWhite ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          child: Text(
                            unicode,
                            style: TextStyle(
                              fontSize: cellSize * 0.8,
                              shadows: isWhite ? [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 1)] : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
        }
      }
    }
    return Stack(children: pieces);
  }

  Offset _getPieceOffset(PieceType type, Player color) {
    // 针对黑色棋子的微调偏移
    if (color == blackPlayer) {
      switch (type) {
        case pawn: return const Offset(1.5, 0);
        case king:
        case queen:
        case rook:
        case bishop:
        case knight:
          return const Offset(1, 0);
        default:
          return Offset.zero;
      }
    }
    return Offset.zero;
  }

  String _getUnicode(PieceType type, Player color) {
    switch (type) {
      case king: return color == whitePlayer ? '♔' : '♚';
      case queen: return color == whitePlayer ? '♕' : '♛';
      case rook: return color == whitePlayer ? '♖' : '♜';
      case bishop: return color == whitePlayer ? '♗' : '♝';
      case knight: return color == whitePlayer ? '♘' : '♞';
      case pawn: return color == whitePlayer ? '♙' : '♟';
      default: return '';
    }
  }
}
