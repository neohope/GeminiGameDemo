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
    const padding = 20.0;
    final cellSize = (boardSize - padding * 2) / 18;

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
                painter: _GoGridPainter(cellSize: cellSize, padding: padding),
                child: Stack(
                  children: [
                    _buildStarPoints(cellSize, padding),
                    ..._buildPieces(cellSize, padding),
                  ],
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

    if (col >= 0 && col < 19 && row >= 0 && row < 19) {
      onMove(row, col);
    }
  }

  Widget _buildStarPoints(double cellSize, double padding) {
    final starPoints = [
      (3, 3), (9, 3), (15, 3),
      (3, 9), (9, 9), (15, 9),
      (3, 15), (9, 15), (15, 15),
    ];

    return Stack(
      children: starPoints.map((point) {
        final r = point.$1;
        final c = point.$2;
        final centerX = padding + c * cellSize;
        final centerY = padding + r * cellSize;
        return Positioned(
          left: centerX - 3,
          top: centerY - 3,
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

  List<Widget> _buildPieces(double cellSize, double padding) {
    final pieces = <Widget>[];
    for (int r = 0; r < 19; r++) {
      for (int c = 0; c < 19; c++) {
        final piece = board.getPiece(r, c);
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
  final double padding;

  _GoGridPainter({required this.cellSize, required this.padding});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    for (int i = 0; i < 19; i++) {
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

    // 绘制星位
    final starPoints = [
      (3, 3), (9, 3), (15, 3),
      (3, 9), (9, 9), (15, 9),
      (3, 15), (9, 15), (15, 15),
    ];
    final starPaint = Paint()..color = Colors.black;
    for (final point in starPoints) {
      final x = padding + point.$2 * cellSize;
      final y = padding + point.$1 * cellSize;
      canvas.drawCircle(Offset(x, y), 3, starPaint);
    }
  }

  @override
  bool shouldRepaint(_GoGridPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize || oldDelegate.padding != padding;
}
