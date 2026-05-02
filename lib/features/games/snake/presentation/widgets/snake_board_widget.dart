import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/snake/domain/entities/snake_board.dart';

class SnakeBoardWidget extends StatelessWidget {
  final SnakeBoard board;
  final Function(Direction) onDirectionChange;
  final VoidCallback? onTap;

  const SnakeBoardWidget({
    super.key,
    required this.board,
    required this.onDirectionChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 350);
    final cellSize = boardSize / board.width;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: GestureDetector(
          onTap: onTap,
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              onDirectionChange(Direction.up);
            } else if (details.primaryVelocity! > 0) {
              onDirectionChange(Direction.down);
            }
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              onDirectionChange(Direction.left);
            } else if (details.primaryVelocity! > 0) {
              onDirectionChange(Direction.right);
            }
          },
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border.all(color: const Color(0xFF16213E), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                _buildGrid(cellSize),
                _buildSnake(cellSize),
                _buildFood(cellSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(double cellSize) {
    final children = <Widget>[];
    for (int i = 0; i < board.width; i++) {
      for (int j = 0; j < board.height; j++) {
        children.add(
          Positioned(
            left: i * cellSize,
            top: j * cellSize,
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF16213E).withValues(alpha: 0.3), width: 0.5),
              ),
            ),
          ),
        );
      }
    }
    return Stack(children: children);
  }

  Widget _buildSnake(double cellSize) {
    final children = <Widget>[];
    for (int i = 0; i < board.snake.length; i++) {
      final point = board.snake[i];
      final isHead = i == 0;
      children.add(
        Positioned(
          left: point.x * cellSize,
          top: point.y * cellSize,
          child: Container(
            width: cellSize - 2,
            height: cellSize - 2,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isHead ? const Color(0xFFE94560) : const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isHead
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: cellSize * 0.15,
                          height: cellSize * 0.15,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: cellSize * 0.1),
                        Container(
                          width: cellSize * 0.15,
                          height: cellSize * 0.15,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      );
    }
    return Stack(children: children);
  }

  Widget _buildFood(double cellSize) {
    return Positioned(
      left: board.food.x * cellSize,
      top: board.food.y * cellSize,
      child: Container(
        width: cellSize - 4,
        height: cellSize - 4,
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Color(0xFFE94560),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
