import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/gomoku/domain/entities/gomoku_board.dart';

typedef MoveCallback = void Function(int row, int col);

class GomokuBoardWidget extends StatelessWidget {
  final GomokuBoard board;
  final bool enabled;
  final MoveCallback onMove;

  const GomokuBoardWidget({
    super.key,
    required this.board,
    required this.enabled,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 750);
    const padding = 20.0;
    final cellSize = (boardSize - padding * 2) / 14;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFDDB35C),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.brown, width: 2),
            ),
            child: GestureDetector(
              onTapDown: enabled ? (details) => _handleTap(details, cellSize, padding) : null,
              child: CustomPaint(
                painter: _GomokuBoardPainter(cellSize: cellSize, padding: padding),
                child: Stack(
                  children: _buildPieces(cellSize, padding),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, double cellSize, double padding) {
    final localPosition = details.localPosition;
    final col = ((localPosition.dx - padding) / cellSize).round();
    final row = ((localPosition.dy - padding) / cellSize).round();

    if (col >= 0 && col < 15 && row >= 0 && row < 15) {
      onMove(row, col);
    }
  }

  List<Widget> _buildPieces(double cellSize, double padding) {
    final pieces = <Widget>[];
    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        final piece = board.getCell(r, c);
        if (piece != null) {
          final centerX = padding + c * cellSize;
          final centerY = padding + r * cellSize;
          final pieceSize = cellSize * 0.85;
          pieces.add(Positioned(
            left: centerX - pieceSize / 2,
            top: centerY - pieceSize / 2,
            child: Container(
              width: pieceSize,
              height: pieceSize,
              decoration: BoxDecoration(
                color: piece == blackPlayer ? Colors.black : Colors.white,
                shape: BoxShape.circle,
                border: piece == whitePlayer ? Border.all(color: Colors.black26, width: 1) : null,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ));
        }
      }
    }
    return pieces;
  }
}

class _GomokuBoardPainter extends CustomPainter {
  final double cellSize;
  final double padding;

  _GomokuBoardPainter({required this.cellSize, required this.padding});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    for (int i = 0; i < 15; i++) {
      final pos = padding + i * cellSize;
      canvas.drawLine(
        Offset(pos, padding),
        Offset(pos, size.height - padding),
        paint,
      );
      canvas.drawLine(
        Offset(padding, pos),
        Offset(size.width - padding, pos),
        paint,
      );
    }

    final starPoints = [
      [3, 3], [11, 3], [7, 7], [3, 11], [11, 11],
    ];
    final starPaint = Paint()..color = Colors.black54;
    for (final point in starPoints) {
      final x = padding + point[1] * cellSize;
      final y = padding + point[0] * cellSize;
      canvas.drawCircle(Offset(x, y), 3, starPaint);
    }
  }

  @override
  bool shouldRepaint(_GomokuBoardPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize || oldDelegate.padding != padding;
}
