import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';

typedef CellTapCallback = void Function(int x, int y);

class ChineseChessBoardWidget extends StatelessWidget {
  final ChineseChessBoard board;
  final Piece? selectedPiece;
  final CellTapCallback onCellTap;
  final bool enabled;

  const ChineseChessBoardWidget({
    super.key,
    required this.board,
    required this.selectedPiece,
    required this.onCellTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 700);
    const sidePadding = 20.0;
    final cellSize = (boardSize - sidePadding * 2) / 8;
    final topBottomPadding = cellSize * 0.5;
    final boardHeight = cellSize * 9 + topBottomPadding * 2;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: boardSize,
          height: boardHeight,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0D9B5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.brown, width: 2),
            ),
            child: GestureDetector(
              onTapDown: enabled ? (details) => _handleTap(details, cellSize, sidePadding, topBottomPadding) : null,
              child: CustomPaint(
                painter: _ChineseChessGridPainter(cellSize: cellSize, sidePadding: sidePadding, topBottomPadding: topBottomPadding),
                child: Stack(
                  children: _buildPieces(cellSize, sidePadding, topBottomPadding),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, double cellSize, double sidePadding, double topBottomPadding) {
    final localPosition = details.localPosition;
    final x = ((localPosition.dx - sidePadding) / cellSize).round();
    final y = ((localPosition.dy - topBottomPadding) / cellSize).round();

    if (x >= 0 && x < 9 && y >= 0 && y < 10) {
      onCellTap(x, y);
    }
  }

  List<Widget> _buildPieces(double cellSize, double sidePadding, double topBottomPadding) {
    final widgets = <Widget>[];
    for (final piece in board.pieces) {
      final isSelected = selectedPiece != null && selectedPiece!.id == piece.id;
      final centerX = sidePadding + piece.x * cellSize;
      final centerY = topBottomPadding + piece.y * cellSize;
      final pieceSize = cellSize * 0.85;

      widgets.add(Positioned(
        left: centerX - pieceSize / 2,
        top: centerY - pieceSize / 2,
        child: GestureDetector(
          onTap: enabled ? () => onCellTap(piece.x, piece.y) : null,
          child: Container(
            width: pieceSize,
            height: pieceSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.brown,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Text(
              piece.text,
              style: TextStyle(
                fontSize: cellSize * 0.45,
                color: piece.color == redPlayer ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _ChineseChessGridPainter extends CustomPainter {
  final double cellSize;
  final double sidePadding;
  final double topBottomPadding;

  _ChineseChessGridPainter({required this.cellSize, required this.sidePadding, required this.topBottomPadding});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 1.5;

    for (int i = 0; i < 10; i++) {
      final y = topBottomPadding + i * cellSize;
      canvas.drawLine(
        Offset(sidePadding, y),
        Offset(sidePadding + 8 * cellSize, y),
        paint,
      );
    }

    for (int i = 0; i < 9; i++) {
      final x = sidePadding + i * cellSize;
      canvas.drawLine(
        Offset(x, topBottomPadding),
        Offset(x, topBottomPadding + 4 * cellSize),
        paint,
      );
    }

    for (int i = 0; i < 9; i++) {
      final x = sidePadding + i * cellSize;
      canvas.drawLine(
        Offset(x, topBottomPadding + 5 * cellSize),
        Offset(x, topBottomPadding + 9 * cellSize),
        paint,
      );
    }

    canvas.drawLine(
      Offset(sidePadding, topBottomPadding),
      Offset(sidePadding, topBottomPadding + 9 * cellSize),
      paint,
    );
    canvas.drawLine(
      Offset(sidePadding + 8 * cellSize, topBottomPadding),
      Offset(sidePadding + 8 * cellSize, topBottomPadding + 9 * cellSize),
      paint,
    );

    canvas.drawLine(
      Offset(sidePadding + 3 * cellSize, topBottomPadding),
      Offset(sidePadding + 5 * cellSize, topBottomPadding + 2 * cellSize),
      paint,
    );
    canvas.drawLine(
      Offset(sidePadding + 5 * cellSize, topBottomPadding),
      Offset(sidePadding + 3 * cellSize, topBottomPadding + 2 * cellSize),
      paint,
    );

    canvas.drawLine(
      Offset(sidePadding + 3 * cellSize, topBottomPadding + 7 * cellSize),
      Offset(sidePadding + 5 * cellSize, topBottomPadding + 9 * cellSize),
      paint,
    );
    canvas.drawLine(
      Offset(sidePadding + 5 * cellSize, topBottomPadding + 7 * cellSize),
      Offset(sidePadding + 3 * cellSize, topBottomPadding + 9 * cellSize),
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '楚河      汉界',
        style: TextStyle(
          color: Colors.brown,
          fontSize: cellSize * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textX = (size.width - textPainter.width) / 2;
    final textY = topBottomPadding + 4 * cellSize + (cellSize - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(_ChineseChessGridPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize || oldDelegate.sidePadding != sidePadding || oldDelegate.topBottomPadding != topBottomPadding;
}
