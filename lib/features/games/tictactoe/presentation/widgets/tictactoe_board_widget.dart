import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/tictactoe/domain/entities/tictactoe_board.dart';

class TicTacToeBoardWidget extends StatelessWidget {
  final TicTacToeBoard board;
  final Function(int row, int col) onTileTap;

  const TicTacToeBoardWidget({
    super.key,
    required this.board,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 450);
    final cellSize = boardSize / 3;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              _buildGrid(boardSize, cellSize),
              _buildTiles(cellSize),
              if (board.winningLine != null) _buildWinningLine(cellSize, board.winningLine!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(double boardSize, double cellSize) {
    return Stack(
      children: [
        // Vertical lines
        Positioned(
          left: cellSize,
          top: 0,
          child: Container(
            width: 3,
            height: boardSize,
            color: const Color(0xFF9FA8DA),
          ),
        ),
        Positioned(
          left: cellSize * 2,
          top: 0,
          child: Container(
            width: 3,
            height: boardSize,
            color: const Color(0xFF9FA8DA),
          ),
        ),
        // Horizontal lines
        Positioned(
          left: 0,
          top: cellSize,
          child: Container(
            width: boardSize,
            height: 3,
            color: const Color(0xFF9FA8DA),
          ),
        ),
        Positioned(
          left: 0,
          top: cellSize * 2,
          child: Container(
            width: boardSize,
            height: 3,
            color: const Color(0xFF9FA8DA),
          ),
        ),
      ],
    );
  }

  Widget _buildTiles(double cellSize) {
    final children = <Widget>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final player = board.getTile(row, col);
        final isWinningTile = board.winningLine?.any((p) => p[0] == row && p[1] == col) ?? false;
        children.add(
          Positioned(
            left: col * cellSize,
            top: row * cellSize,
            child: GestureDetector(
              onTap: () => onTileTap(row, col),
              child: Container(
                width: cellSize,
                height: cellSize,
                color: Colors.transparent,
                child: Center(
                  child: player != Player.none
                      ? Text(
                          player == Player.x ? 'X' : 'O',
                          style: TextStyle(
                            fontSize: cellSize * 0.6,
                            fontWeight: FontWeight.bold,
                            color: isWinningTile
                                ? const Color(0xFFFF5252)
                                : (player == Player.x ? const Color(0xFF3949AB) : const Color(0xFF66BB6A)),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      }
    }
    return Stack(children: children);
  }

  Widget _buildWinningLine(double cellSize, List<List<int>> winningLine) {
    final start = winningLine.first;
    final end = winningLine.last;

    final startX = start[1] * cellSize + cellSize / 2;
    final startY = start[0] * cellSize + cellSize / 2;
    final endX = end[1] * cellSize + cellSize / 2;
    final endY = end[0] * cellSize + cellSize / 2;

    return CustomPaint(
      painter: _WinningLinePainter(
        start: Offset(startX, startY),
        end: Offset(endX, endY),
      ),
    );
  }
}

class _WinningLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  _WinningLinePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
