import 'dart:math';
import 'package:neo_game_suit/features/games/fall100/domain/entities/fall100_board.dart';

class Fall100Logic {
  static const double gravity = 0.4;
  static const double maxFallSpeed = 12.0;
  static const double jumpForce = -10.0;
  static const double moveSpeed = 5.0;
  static const double platformSpacing = 100.0;

  static Fall100Board update(Fall100Board board, double moveDirection) {
    if (board.status != GameStatus.playing) return board;

    Player newPlayer = _updatePlayer(board.player, board, moveDirection);
    List<Platform> newPlatforms = List.from(board.platforms);
    int newFloor = board.floor;
    int newScore = board.score;
    double newCameraY = board.cameraY;

    // Check platform collisions
    for (int i = 0; i < newPlatforms.length; i++) {
      final platform = newPlatforms[i];
      if (_checkPlatformCollision(newPlayer, platform)) {
        if (platform.type == PlatformType.spike) {
          // Game over on spike
          return board.copyWith(
            status: GameStatus.gameOver,
            highScore: max(board.score, board.highScore),
          );
        }
        if (newPlayer.velocityY > 0) {
          // Landing on platform
          newPlayer = newPlayer.copyWith(
            y: platform.y - newPlayer.size,
            velocityY: jumpForce,
          );

          if (platform.type == PlatformType.breakable) {
            newPlatforms.removeAt(i);
          }
        }
      }
    }

    // Move platforms with camera
    final targetCameraY = _getTargetCameraY(newPlayer, board);
    if (targetCameraY > newCameraY) {
      newCameraY = targetCameraY;

      // Calculate new floor
      final floorFromCamera = (newCameraY / platformSpacing).floor();
      if (floorFromCamera > newFloor) {
        newFloor = floorFromCamera;
        newScore = newFloor;
      }

      // Generate new platforms above
      final topPlatformY = newPlatforms.map((p) => p.y).reduce(min);
      while (topPlatformY > -newCameraY - platformSpacing * 10) {
        final newY = topPlatformY - platformSpacing - Random().nextDouble() * 50;
        newPlatforms.add(_generatePlatform(board.worldWidth, newY, newFloor + 20));
      }

      // Remove platforms that are way below
      newPlatforms.removeWhere((p) => p.y > -newCameraY + board.worldHeight + 200);
    }

    // Check if player fell off the bottom
    if (newPlayer.y > -newCameraY + board.worldHeight + 100) {
      return board.copyWith(
        status: GameStatus.gameOver,
        highScore: max(board.score, board.highScore),
      );
    }

    return board.copyWith(
      player: newPlayer,
      platforms: newPlatforms,
      floor: newFloor,
      score: newScore,
      cameraY: newCameraY,
    );
  }

  static Player _updatePlayer(Player player, Fall100Board board, double moveDirection) {
    double newX = player.x + moveDirection * moveSpeed;
    double newY = player.y + player.velocityY;
    double newVelocityY = player.velocityY + gravity;

    // Cap fall speed
    if (newVelocityY > maxFallSpeed) {
      newVelocityY = maxFallSpeed;
    }

    // Wrap around screen
    if (newX < -player.size) {
      newX = board.worldWidth;
    } else if (newX > board.worldWidth) {
      newX = -player.size;
    }

    bool facingRight = player.facingRight;
    if (moveDirection > 0) {
      facingRight = true;
    } else if (moveDirection < 0) {
      facingRight = false;
    }

    return player.copyWith(
      x: newX,
      y: newY,
      velocityY: newVelocityY,
      facingRight: facingRight,
    );
  }

  static bool _checkPlatformCollision(Player player, Platform platform) {
    final playerBottom = player.y + player.size;
    final playerLeft = player.x + 5;
    final playerRight = player.x + player.size - 5;

    final platformTop = platform.y;
    final platformLeft = platform.x;
    final platformRight = platform.x + platform.width;

    if (player.velocityY <= 0) return false; // Only collide when falling

    if (playerBottom >= platformTop &&
        playerBottom <= platformTop + platform.height + 10 &&
        playerRight > platformLeft &&
        playerLeft < platformRight) {
      return true;
    }
    return false;
  }

  static double _getTargetCameraY(Player player, Fall100Board board) {
    final targetY = -player.y + board.worldHeight * 0.4;
    return max(board.cameraY, targetY);
  }

  static Platform _generatePlatform(double worldWidth, double y, int floor) {
    final random = (y.toInt() * 13 + floor * 7) % 100;
    final x = (random / 100.0) * (worldWidth - 100) + 20;

    PlatformType type;
    final typeRandom = (random + floor * 3) % 100;
    if (typeRandom < 60) {
      type = PlatformType.normal;
    } else if (typeRandom < 80) {
      type = PlatformType.breakable;
    } else if (typeRandom < 95) {
      type = PlatformType.spike;
    } else {
      type = PlatformType.moving;
    }

    return Platform(
      x: x,
      y: y,
      width: 70 + (random % 40).toDouble(),
      height: 15,
      type: type,
    );
  }

  static Fall100Board startGame(Fall100Board board) {
    return board.copyWith(status: GameStatus.playing);
  }

  static Fall100Board reset(Fall100Board board) {
    return Fall100Board.initial(board.worldWidth, board.worldHeight).copyWith(
      highScore: max(board.score, board.highScore),
    );
  }
}
