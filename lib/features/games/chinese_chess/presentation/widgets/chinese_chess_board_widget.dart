import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';

typedef CellTapCallback = void Function(int x, int y);

class ChineseChessBoardWidget extends StatelessWidget {
  final ChineseChessBoard board;
  final Piece? selectedPiece;
  final CellTapCallback onCellTap;

  const ChineseChessBoardWidget({
    super.key,
    required this.board,
    required this.selectedPiece,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 500);
    final cellSize = boardSize / 9;

    return Center(
      child: Container(
        width: boardSize,
        height: boardSize * 10 / 9,
        decoration: BoxDecoration(
          color: const Color(0xFFF0D9B5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown, width: 2),
        ),
        child: _buildBoard(context, cellSize),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, double cellSize) {
    return Stack(
      children: [
        _buildGridLines(cellSize),
        _buildRiverText(cellSize),
        ..._buildPieces(context, cellSize),
        _buildIntersections(cellSize),
      ],
    );
  }

  Widget _buildGridLines(double cellSize) {
    return CustomPaint(
      size: Size(cellSize * 9, cellSize * 10),
      painter: _ChineseChessGridPainter(cellSize: cellSize),
    );
  }

  Widget _buildRiverText(double cellSize) {
    return Positioned(
      top: cellSize * 4.5,
      left: cellSize * 1,
      right: cellSize * 1,
      child: Text(
        '楚河 汉界',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: cellSize * 0.6, color: Colors.brown[400]),
      ),
    );
  }

  List<Widget> _buildPieces(BuildContext context, double cellSize) {
    final widgets = <Widget>[];
    for (final piece in board.pieces) {
      final isSelected = selectedPiece != null && selectedPiece!.id == piece.id;
      widgets.add(Positioned(
        left: piece.x * cellSize,
        top: piece.y * cellSize,
        child: GestureDetector(
          onTap: () => onCellTap(piece.x, piece.y),
          child: Container(
            width: cellSize,
            height: cellSize,
            alignment: Alignment.center,
            child: Container(
              width: cellSize * 0.8,
              height: cellSize * 0.8,
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
              child: Center(
                child: Text(
                  piece.text,
                  style: TextStyle(
                    fontSize: cellSize * 0.5,
                    color: piece.color == redPlayer ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildIntersections(double cellSize) {
    final widgets = <Widget>[];
    for (int y = 0; y < 10; y++) {
      for (int x = 0; x < 9; x++) {
        if (board.getPieceAt(x, y) == null) {
          widgets.add(Positioned(
            left: x * cellSize,
            top: y * cellSize,
            child: GestureDetector(
              onTap: () => onCellTap(x, y),
              child: SizedBox(width: cellSize, height: cellSize),
            ),
          ));
        }
      }
    }
    return Stack(children: widgets);
  }
}

class _ChineseChessGridPainter extends CustomPainter {
  final double cellSize;

  _ChineseChessGridPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 1.5;

    for (int y = 0; y < 10; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(8 * cellSize, y * cellSize),
        paint,
      );
    }

    for (int x = 0; x < 9; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, 4 * cellSize),
        paint,
      );
      canvas.drawLine(
        Offset(x * cellSize, 5 * cellSize),
        Offset(x * cellSize, 9 * cellSize),
        paint,
      );
    }

    canvas.drawLine(Offset(0, 0), Offset(0, 9 * cellSize), paint);
    canvas.drawLine(Offset(8 * cellSize, 0), Offset(8 * cellSize, 9 * cellSize), paint);

    canvas.drawLine(Offset(3 * cellSize, 0), Offset(5 * cellSize, 2 * cellSize), paint);
    canvas.drawLine(Offset(5 * cellSize, 0), Offset(3 * cellSize, 2 * cellSize), paint);
    canvas.drawLine(Offset(3 * cellSize, 7 * cellSize), Offset(5 * cellSize, 9 * cellSize), paint);
    canvas.drawLine(Offset(5 * cellSize, 7 * cellSize), Offset(3 * cellSize, 9 * cellSize), paint);
  }

  @override
  bool shouldRepaint(_ChineseChessGridPainter oldDelegate) => oldDelegate.cellSize != cellSize;
}
