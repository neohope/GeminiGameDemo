import 'dart:math';
import 'package:neo_game_suit/features/games/dino/domain/entities/dino_board.dart';

class DinoLogic {
  static const double gravity = 0.6;
  static const double jumpForce = -12.0;
  static const double groundY = 0.0;
  static const double minObstacleSpacing = 400;
  static const double maxObstacleSpacing = 600;
  static const double maxGameSpeed = 12.0;
  static const double speedIncrement = 0.001;

  static DinoBoard update(DinoBoard board) {
    if (board.status != GameStatus.playing) return board;

    final newSpeed = min(board.gameSpeed + speedIncrement, maxGameSpeed);

    Dino newDino = _updateDino(board.dino, board.groundY);
    List<Obstacle> newObstacles = _updateObstacles(board.obstacles, board.worldWidth, newSpeed);
    List<Cloud> newClouds = _updateClouds(board.clouds, board.worldWidth, newSpeed);
    int newScore = board.score;

    // Check for collisions
    if (_checkCollision(newDino, newObstacles, board.groundY)) {
      return board.copyWith(
        status: GameStatus.gameOver,
        highScore: max(board.score, board.highScore),
      );
    }

    // Update score when passing obstacles
    for (int i = 0; i < newObstacles.length; i++) {
      if (!newObstacles[i].passed && newObstacles[i].x + newObstacles[i].width < 100) {
        newObstacles[i] = newObstacles[i].copyWith(passed: true);
        newScore++;
      }
    }

    // Spawn new obstacles
    if (newObstacles.isEmpty ||
        board.worldWidth - newObstacles.last.x > _getRandomSpacing()) {
      newObstacles.add(_spawnObstacle(board.worldWidth, board.groundY));
    }

    // Spawn new clouds
    if (newClouds.isEmpty ||
        board.worldWidth - newClouds.last.x > 300 + Random().nextDouble() * 200) {
      newClouds.add(_spawnCloud(board.worldWidth, board.worldHeight));
    }

    return board.copyWith(
      dino: newDino,
      obstacles: newObstacles,
      clouds: newClouds,
      score: newScore,
      gameSpeed: newSpeed,
    );
  }

  static Dino _updateDino(Dino dino, double groundY) {
    double newY = dino.y + dino.velocity;
    double newVelocity = dino.velocity + gravity;

    // Ground collision
    if (newY >= groundY) {
      newY = groundY;
      newVelocity = 0;
    }

    return dino.copyWith(y: newY, velocity: newVelocity);
  }

  static List<Obstacle> _updateObstacles(
    List<Obstacle> obstacles,
    double worldWidth,
    double gameSpeed,
  ) {
    return obstacles
        .map((obstacle) => obstacle.copyWith(x: obstacle.x - gameSpeed))
        .where((obstacle) => obstacle.x + obstacle.width > -100)
        .toList();
  }

  static List<Cloud> _updateClouds(
    List<Cloud> clouds,
    double worldWidth,
    double gameSpeed,
  ) {
    final updated = clouds
        .map((cloud) => cloud.copyWith(x: cloud.x - gameSpeed * 0.3))
        .where((cloud) => cloud.x + cloud.size > -50)
        .toList();
    return updated;
  }

  static bool _checkCollision(Dino dino, List<Obstacle> obstacles, double groundY) {
    const double hitboxPadding = 15;

    final dinoLeft = 100 - hitboxPadding;
    final dinoRight = 100 + dino.size - hitboxPadding;
    final dinoTop = dino.y - (dino.isDucking ? dino.size * 0.4 : 0) + hitboxPadding;
    final dinoBottom = dino.y + dino.size - hitboxPadding;

    for (final obstacle in obstacles) {
      final obsLeft = obstacle.x + hitboxPadding;
      final obsRight = obstacle.x + obstacle.width - hitboxPadding;
      final obsTop = obstacle.y + hitboxPadding;
      final obsBottom = obstacle.y + obstacle.height - hitboxPadding;

      if (dinoRight > obsLeft &&
          dinoLeft < obsRight &&
          dinoBottom > obsTop &&
          dinoTop < obsBottom) {
        return true;
      }
    }

    return false;
  }

  static Obstacle _spawnObstacle(double worldWidth, double groundY) {
    final random = Random();
    final type = ObstacleType.values[random.nextInt(ObstacleType.values.length)];

    double width, height, y;

    switch (type) {
      case ObstacleType.smallCactus:
        width = 30 + random.nextDouble() * 20;
        height = 40 + random.nextDouble() * 20;
        y = groundY - height;
        break;
      case ObstacleType.largeCactus:
        width = 50 + random.nextDouble() * 30;
        height = 60 + random.nextDouble() * 30;
        y = groundY - height;
        break;
      case ObstacleType.bird:
        width = 50;
        height = 40;
        // Birds can be at different heights
        final birdHeightOption = random.nextInt(3);
        if (birdHeightOption == 0) {
          y = groundY - 120;
        } else if (birdHeightOption == 1) {
          y = groundY - 80;
        } else {
          y = groundY - 50;
        }
        break;
    }

    return Obstacle(
      x: worldWidth + 100,
      width: width,
      height: height,
      y: y,
      type: type,
    );
  }

  static Cloud _spawnCloud(double worldWidth, double worldHeight) {
    final random = Random();
    return Cloud(
      x: worldWidth + 50,
      y: 50 + random.nextDouble() * (worldHeight * 0.3),
      size: 40 + random.nextDouble() * 40,
    );
  }

  static double _getRandomSpacing() {
    return minObstacleSpacing + Random().nextDouble() * (maxObstacleSpacing - minObstacleSpacing);
  }

  static DinoBoard jump(DinoBoard board) {
    if (board.status == GameStatus.ready) {
      return board.copyWith(status: GameStatus.playing);
    }
    if (board.status == GameStatus.gameOver) return board;

    // Only jump if on the ground
    if (board.dino.y >= board.groundY - 1) {
      return board.copyWith(
        dino: board.dino.copyWith(velocity: jumpForce),
      );
    }
    return board;
  }

  static DinoBoard duck(DinoBoard board, bool isDucking) {
    if (board.status != GameStatus.playing) return board;
    return board.copyWith(
      dino: board.dino.copyWith(isDucking: isDucking),
    );
  }

  static DinoBoard reset(DinoBoard board) {
    return DinoBoard.initial(board.worldWidth, board.worldHeight).copyWith(
      highScore: max(board.score, board.highScore),
    );
  }
}
