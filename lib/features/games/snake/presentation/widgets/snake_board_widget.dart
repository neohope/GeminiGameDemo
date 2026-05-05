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
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 900);
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
              color: const Color(0xFF3d405b),
              border: Border.all(color: const Color(0xFF81b29a), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                _buildGrid(cellSize),
                _buildFood(cellSize),
                _buildSnake(cellSize),
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
                border: Border.all(color: const Color(0xFF81b29a).withValues(alpha: 0.3), width: 0.5),
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
              color: isHead ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isHead
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
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
        decoration: BoxDecoration(
          color: const Color(0xFFFFE66D),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFE66D).withValues(alpha: 0.6),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}
