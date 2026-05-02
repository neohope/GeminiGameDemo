import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/reversi/domain/entities/reversi_board.dart';
import 'package:neo_game_suit/features/games/reversi/domain/usecases/reversi_logic.dart';

class ReversiBoardWidget extends StatelessWidget {
  final ReversiBoard board;
  final Function(int row, int col) onTileTap;

  const ReversiBoardWidget({
    super.key,
    required this.board,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 350);
    final cellSize = boardSize / 8;

    final validMoves = ReversiLogic.getValidMoves(board, board.currentPlayer);

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: const Color(0xFF2D5016),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1A1A2E), width: 4),
          ),
          child: Stack(
            children: [
              _buildGrid(cellSize),
              _buildTiles(cellSize, validMoves),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(double cellSize) {
    final children = <Widget>[];
    // Draw grid lines
    for (int i = 1; i < 8; i++) {
      children.add(
        Positioned(
          left: i * cellSize,
          top: 0,
          child: Container(
            width: 1,
            height: cellSize * 8,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
      );
      children.add(
        Positioned(
          left: 0,
          top: i * cellSize,
          child: Container(
            width: cellSize * 8,
            height: 1,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    return Stack(children: children);
  }

  Widget _buildTiles(double cellSize, List<(int, int)> validMoves) {
    final children = <Widget>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final player = board.getTile(row, col);
        final isValidMove = validMoves.any((m) => m.$1 == row && m.$2 == col);
        final isLastMove = board.lastMove != null && board.lastMove!.$1 == row && board.lastMove!.$2 == col;
        final isLastFlipped = board.lastFlipped?.any((p) => p[0] == row && p[1] == col) ?? false;

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
                      ? _buildPiece(cellSize, player, isLastMove || isLastFlipped)
                      : isValidMove
                          ? _buildValidMoveIndicator(cellSize)
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

  Widget _buildPiece(double cellSize, Player player, bool highlight) {
    return Container(
      width: cellSize * 0.8,
      height: cellSize * 0.8,
      decoration: BoxDecoration(
        color: player == Player.black ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        border: highlight
            ? Border.all(color: const Color(0xFFE94560), width: 3)
            : Border.all(color: Colors.black.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildValidMoveIndicator(double cellSize) {
    return Container(
      width: cellSize * 0.3,
      height: cellSize * 0.3,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
