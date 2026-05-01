import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/go/domain/entities/go_board.dart';

typedef MoveCallback = void Function(int row, int col);

class GoBoardWidget extends StatelessWidget {
  final GoBoard board;
  final bool enabled;
  final MoveCallback onMove;

  const GoBoardWidget({
    super.key,
    required this.board,
    required this.enabled,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 550);
    final cellSize = boardSize / 19;

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
          child: Stack(
            children: [
              _buildGridLines(cellSize),
              _buildStarPoints(cellSize),
              ..._buildPieces(cellSize),
            ],
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

    if (col >= 0 && col < 19 && row >= 0 && row < 19) {
      onMove(row, col);
    }
  }

  Widget _buildGridLines(double cellSize) {
    return CustomPaint(
      size: Size(cellSize * 19, cellSize * 19),
      painter: _GoGridPainter(cellSize: cellSize),
    );
  }

  Widget _buildStarPoints(double cellSize) {
    final starPoints = [
      (3, 3), (9, 3), (15, 3),
      (3, 9), (9, 9), (15, 9),
      (3, 15), (9, 15), (15, 15),
    ];

    return Stack(
      children: starPoints.map((point) {
        final r = point.$1;
        final c = point.$2;
        return Positioned(
          left: c * cellSize - 3,
          top: r * cellSize - 3,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildPieces(double cellSize) {
    final pieces = <Widget>[];
    for (int r = 0; r < 19; r++) {
      for (int c = 0; c < 19; c++) {
        final piece = board.getPiece(r, c);
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
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

class _GoGridPainter extends CustomPainter {
  final double cellSize;

  _GoGridPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    for (int i = 0; i < 19; i++) {
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
  }

  @override
  bool shouldRepaint(_GoGridPainter oldDelegate) => oldDelegate.cellSize != cellSize;
}
