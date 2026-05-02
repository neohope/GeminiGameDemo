import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/tetris/domain/entities/tetris_board.dart';

class TetrisBoardWidget extends StatelessWidget {
  final TetrisBoard board;

  const TetrisBoardWidget({
    super.key,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 500);
    final cellSize = boardSize / TetrisBoard.cols;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: boardSize,
          height: cellSize * TetrisBoard.rows,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFF333333),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Board grid
              _buildBoard(board, cellSize),
              // Current piece
              _buildCurrentPiece(board, cellSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(TetrisBoard board, double cellSize) {
    final children = <Widget>[];

    for (int y = 0; y < TetrisBoard.rows; y++) {
      for (int x = 0; x < TetrisBoard.cols; x++) {
        final type = board.board[y][x];
        children.add(
          Positioned(
            left: x * cellSize,
            top: y * cellSize,
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF2A2A2A),
                  width: 1,
                ),
                color: type != null
                    ? TetrisBoard.getTypeColor(type).withValues(alpha: 0.9)
                    : null,
              ),
              child: type != null
                  ? _buildCellDecoration(TetrisBoard.getTypeColor(type))
                  : null,
            ),
          ),
        );
      }
    }

    return Stack(children: children);
  }

  Widget _buildCurrentPiece(TetrisBoard board, double cellSize) {
    final children = <Widget>[];
    final shape = board.currentPiece.shape;
    final color = board.currentPiece.color;

    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          final boardX = board.currentPiece.x + x;
          final boardY = board.currentPiece.y + y;
          if (boardY >= 0 && boardY < TetrisBoard.rows && boardX >= 0 && boardX < TetrisBoard.cols) {
            children.add(
              Positioned(
                left: boardX * cellSize,
                top: boardY * cellSize,
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.9),
                  ),
                  child: _buildCellDecoration(color),
                ),
              ),
            );
          }
        }
      }
    }

    return Stack(children: children);
  }

  Widget _buildCellDecoration(Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class TetrisNextPieceWidget extends StatelessWidget {
  final TetrisBoard board;

  const TetrisNextPieceWidget({
    super.key,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = 20.0;
    final shape = board.nextPiece.shape;
    final color = board.nextPiece.color;

    // Center piece in preview area
    final offsetX = ((TetrisBoard.previewCols - shape[0].length) / 2) * cellSize;
    final offsetY = ((TetrisBoard.previewRows - shape.length) / 2) * cellSize;

    final children = <Widget>[];

    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          children.add(
            Positioned(
              left: offsetX + x * cellSize,
              top: offsetY + y * cellSize,
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.9),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Container(
      width: cellSize * TetrisBoard.previewCols,
      height: cellSize * TetrisBoard.previewRows,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: children,
      ),
    );
  }
}
