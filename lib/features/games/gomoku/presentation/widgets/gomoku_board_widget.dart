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
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 550);
    final cellSize = boardSize / 15;

    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(0xFFDDB35C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown, width: 2),
        ),
        child: GestureDetector(
          onTapDown: enabled ? (details) => _handleTap(details, cellSize, boardSize, context) : null,
          child: CustomPaint(
            painter: _GomokuBoardPainter(cellSize: cellSize),
            child: Stack(
              children: _buildPieces(cellSize),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, double cellSize, double boardSize, BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final col = (localPosition.dx / cellSize).round();
    final row = (localPosition.dy / cellSize).round();

    if (col >= 0 && col < 15 && row >= 0 && row < 15) {
      onMove(row, col);
    }
  }

  List<Widget> _buildPieces(double cellSize) {
    final pieces = <Widget>[];
    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        final piece = board.getCell(r, c);
        if (piece != null) {
          pieces.add(Positioned(
            left: c * cellSize - cellSize / 2 + cellSize / 2,
            top: r * cellSize - cellSize / 2 + cellSize / 2,
            child: Container(
              width: cellSize * 0.85,
              height: cellSize * 0.85,
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

  _GomokuBoardPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    for (int i = 0; i < 15; i++) {
      canvas.drawLine(
        Offset(i * cellSize + cellSize / 2, cellSize / 2),
        Offset(i * cellSize + cellSize / 2, size.height - cellSize / 2),
        paint,
      );
      canvas.drawLine(
        Offset(cellSize / 2, i * cellSize + cellSize / 2),
        Offset(size.width - cellSize / 2, i * cellSize + cellSize / 2),
        paint,
      );
    }

    final starPoints = [
      [3, 3], [11, 3], [7, 7], [3, 11], [11, 11],
    ];
    final starPaint = Paint()..color = Colors.black54;
    for (final point in starPoints) {
      final x = point[1] * cellSize + cellSize / 2;
      final y = point[0] * cellSize + cellSize / 2;
      canvas.drawCircle(Offset(x, y), 3, starPaint);
    }
  }

  @override
  bool shouldRepaint(_GomokuBoardPainter oldDelegate) => oldDelegate.cellSize != cellSize;
}
