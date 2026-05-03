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
          pieces.add(Positioned(
            left: c * cellSize,
            top: r * cellSize,
            child: Container(
              width: cellSize,
              height: cellSize,
              alignment: Alignment.center,
              child: Text(
                unicode,
                style: TextStyle(
                  fontSize: cellSize * 0.8,
                  color: isWhite ? Colors.white : Colors.black,
                  shadows: isWhite ? [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 1)] : null,
                ),
              ),
            ),
          ));
        }
      }
    }
    return Stack(children: pieces);
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
