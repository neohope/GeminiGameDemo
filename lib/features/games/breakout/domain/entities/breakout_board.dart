import 'package:flutter/material.dart';

class Ball {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double radius;

  Ball({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.radius,
  });

  Ball copyWith({
    double? x,
    double? y,
    double? velocityX,
    double? velocityY,
    double? radius,
  }) {
    return Ball(
      x: x ?? this.x,
      y: y ?? this.y,
      velocityX: velocityX ?? this.velocityX,
      velocityY: velocityY ?? this.velocityY,
      radius: radius ?? this.radius,
    );
  }
}

class Paddle {
  final double x;
  final double y;
  final double width;
  final double height;

  Paddle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Paddle copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return Paddle(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class Brick {
  final double x;
  final double y;
  final double width;
  final double height;
  final BrickType type;
  final int hits;
  final Color color;

  Brick({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    required this.hits,
    required this.color,
  });

  Brick copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    BrickType? type,
    int? hits,
    Color? color,
  }) {
    return Brick(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
      hits: hits ?? this.hits,
      color: color ?? this.color,
    );
  }
}

enum BrickType {
  normal,
  hard,
  unbreakable,
}

class BreakoutBoard {
  final Ball ball;
  final Paddle paddle;
  final List<Brick> bricks;
  final int score;
  final int highScore;
  final int lives;
  final int level;
  final GameStatus status;
  final double worldHeight;
  final double worldWidth;

  BreakoutBoard({
    required this.ball,
    required this.paddle,
    required this.bricks,
    required this.score,
    required this.highScore,
    required this.lives,
    required this.level,
    required this.status,
    required this.worldHeight,
    required this.worldWidth,
  });

  static List<Brick> _generateBricks(double worldWidth) {
    final bricks = <Brick>[];
    const rows = 5;
    const cols = 10;
    const padding = 20.0;
    const gap = 4.0;
    const brickHeight = 25.0;
    final totalGapWidth = (cols - 1) * gap;
    final brickWidth = (worldWidth - padding * 2 - totalGapWidth) / cols;
    final startX = (worldWidth - (brickWidth * cols + totalGapWidth)) / 2;
    final colors = [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFF96CEB4),
    ];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = startX + col * (brickWidth + gap);
        final y = 80.0 + row * (brickHeight + gap);
        final type = row < 1
            ? BrickType.hard
            : BrickType.normal;

        bricks.add(Brick(
          x: x,
          y: y,
          width: brickWidth,
          height: brickHeight,
          type: type,
          hits: type == BrickType.hard ? 2 : 1,
          color: colors[row % colors.length],
        ));
      }
    }
    return bricks;
  }

  factory BreakoutBoard.initial(double worldWidth, double worldHeight) {
    return BreakoutBoard(
      ball: Ball(
        x: worldWidth / 2,
        y: worldHeight - 100,
        velocityX: 3,
        velocityY: -4,
        radius: 10,
      ),
      paddle: Paddle(
        x: worldWidth / 2 - 50,
        y: worldHeight - 60,
        width: 100,
        height: 15,
      ),
      bricks: _generateBricks(worldWidth),
      score: 0,
      highScore: 0,
      lives: 3,
      level: 1,
      status: GameStatus.ready,
      worldHeight: worldHeight,
      worldWidth: worldWidth,
    );
  }

  factory BreakoutBoard.initialLevel(BreakoutBoard prev) {
    return BreakoutBoard(
      ball: Ball(
        x: prev.worldWidth / 2,
        y: prev.worldHeight - 100,
        velocityX: 3 + prev.level * 0.5,
        velocityY: -4 - prev.level * 0.3,
        radius: 10,
      ),
      paddle: Paddle(
        x: prev.worldWidth / 2 - 50,
        y: prev.worldHeight - 60,
        width: 100,
        height: 15,
      ),
      bricks: _generateBricks(prev.worldWidth),
      score: prev.score,
      highScore: prev.highScore,
      lives: prev.lives,
      level: prev.level + 1,
      status: GameStatus.ready,
      worldHeight: prev.worldHeight,
      worldWidth: prev.worldWidth,
    );
  }

  BreakoutBoard copyWith({
    Ball? ball,
    Paddle? paddle,
    List<Brick>? bricks,
    int? score,
    int? highScore,
    int? lives,
    int? level,
    GameStatus? status,
    double? worldHeight,
    double? worldWidth,
  }) {
    return BreakoutBoard(
      ball: ball ?? this.ball,
      paddle: paddle ?? this.paddle,
      bricks: bricks ?? this.bricks,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      lives: lives ?? this.lives,
      level: level ?? this.level,
      status: status ?? this.status,
      worldHeight: worldHeight ?? this.worldHeight,
      worldWidth: worldWidth ?? this.worldWidth,
    );
  }
}

enum GameStatus {
  ready,
  playing,
  gameOver,
  won,
}
