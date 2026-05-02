import 'dart:math';
import 'package:neo_game_suit/features/games/snake/domain/entities/snake_board.dart';

class SnakeLogic {
  static SnakeBoard move(SnakeBoard board) {
    if (board.isGameOver || board.isPaused) return board;

    final effectiveDirection = board.nextDirection ?? board.direction;
    final head = board.snake.first;
    final newHead = head.move(effectiveDirection);

    // Check wall collision
    if (newHead.x < 0 ||
        newHead.x >= board.width ||
        newHead.y < 0 ||
        newHead.y >= board.height) {
      return board.copyWith(isGameOver: true);
    }

    // Check self collision
    if (board.snake.sublist(0, board.snake.length - 1).contains(newHead)) {
      return board.copyWith(isGameOver: true);
    }

    final newSnake = [newHead, ...board.snake];

    // Check food collision
    if (newHead == board.food) {
      final newScore = board.score + 10;
      final newSpeed = max(50, board.speed - 5);
      final newFood = _generateFood(newSnake, board.width, board.height);
      return board.copyWith(
        snake: newSnake,
        food: newFood,
        direction: effectiveDirection,
        nextDirection: null,
        score: newScore,
        speed: newSpeed,
      );
    } else {
      newSnake.removeLast();
      return board.copyWith(
        snake: newSnake,
        direction: effectiveDirection,
        nextDirection: null,
      );
    }
  }

  static SnakeBoard changeDirection(SnakeBoard board, Direction newDirection) {
    final current = board.nextDirection ?? board.direction;

    // Prevent 180-degree turns
    if ((current == Direction.up && newDirection == Direction.down) ||
        (current == Direction.down && newDirection == Direction.up) ||
        (current == Direction.left && newDirection == Direction.right) ||
        (current == Direction.right && newDirection == Direction.left)) {
      return board;
    }

    return board.copyWith(nextDirection: newDirection);
  }

  static SnakeBoard reset() {
    return SnakeBoard.initial();
  }

  static SnakeBoard togglePause(SnakeBoard board) {
    return board.copyWith(isPaused: !board.isPaused);
  }

  static Point _generateFood(List<Point> snake, int width, int height) {
    final random = Random();
    while (true) {
      final x = random.nextInt(width);
      final y = random.nextInt(height);
      final point = Point(x, y);
      if (!snake.contains(point)) {
        return point;
      }
    }
  }
}
