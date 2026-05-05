import 'package:neo_game_suit/features/games/breakout/domain/entities/breakout_board.dart';

class BreakoutLogic {
  static BreakoutBoard update(BreakoutBoard board, double paddleX) {
    if (board.status != GameStatus.playing) return board;

    // Update paddle position with clamping
    double newPaddleX = paddleX;
    if (newPaddleX < 0) newPaddleX = 0;
    if (newPaddleX + board.paddle.width > board.worldWidth) {
      newPaddleX = board.worldWidth - board.paddle.width;
    }

    // Move ball
    double newBallX = board.ball.x + board.ball.velocityX;
    double newBallY = board.ball.y + board.ball.velocityY;
    double newVelocityX = board.ball.velocityX;
    double newVelocityY = board.ball.velocityY;
    List<Brick> newBricks = List.from(board.bricks);
    int newScore = board.score;
    int newLives = board.lives;
    GameStatus newStatus = GameStatus.playing;

    // Wall collision (left/right)
    if (newBallX - board.ball.radius < 0) {
      newBallX = board.ball.radius;
      newVelocityX = newVelocityX.abs();
    } else if (newBallX + board.ball.radius > board.worldWidth) {
      newBallX = board.worldWidth - board.ball.radius;
      newVelocityX = -newVelocityX.abs();
    }

    // Wall collision (top)
    if (newBallY - board.ball.radius < 0) {
      newBallY = board.ball.radius;
      newVelocityY = newVelocityY.abs();
    }

    // Paddle collision
    if (newBallY + board.ball.radius > board.paddle.y &&
        newBallY - board.ball.radius < board.paddle.y + board.paddle.height &&
        newBallX > newPaddleX &&
        newBallX < newPaddleX + board.paddle.width) {
      newBallY = board.paddle.y - board.ball.radius;
      newVelocityY = -newVelocityY.abs();

      // Add angle based on where the ball hits the paddle
      final hitPosition = (newBallX - newPaddleX) / board.paddle.width;
      final angle = (hitPosition - 0.5) * 2.0; // -1 to 1
      final speed = newVelocityX.abs() + newVelocityY.abs();
      newVelocityX = angle * speed * 0.6;
      newVelocityY = -newVelocityY.abs();
    }

    // Bottom collision (lose life)
    if (newBallY > board.worldHeight + board.ball.radius * 2) {
      newLives--;
      if (newLives <= 0) {
        newStatus = GameStatus.gameOver;
      } else {
        newBallX = board.worldWidth / 2;
        newBallY = board.worldHeight - 100;
        newVelocityX = 3;
        newVelocityY = -4;
        newStatus = GameStatus.ready;
      }
    }

    // Brick collision
    for (int i = newBricks.length - 1; i >= 0; i--) {
      final brick = newBricks[i];
      if (_checkBrickCollision(newBallX, newBallY, board.ball.radius, brick)) {
        // Determine collision side
        final dx = (newBallX - (brick.x + brick.width / 2)).abs();
        final dy = (newBallY - (brick.y + brick.height / 2)).abs();
        final overlapX = brick.width / 2 + board.ball.radius - dx;
        final overlapY = brick.height / 2 + board.ball.radius - dy;

        if (overlapX < overlapY) {
          newVelocityX = -newVelocityX;
        } else {
          newVelocityY = -newVelocityY;
        }

        // Update brick
        if (brick.type != BrickType.unbreakable) {
          final newHits = brick.hits - 1;
          if (newHits <= 0) {
            newBricks.removeAt(i);
            newScore += brick.type == BrickType.hard ? 10 : 5;
          } else {
            newBricks[i] = brick.copyWith(hits: newHits);
          }
        }
        break;
      }
    }

    // Check win
    final normalBricks = newBricks.where((b) => b.type != BrickType.unbreakable).length;
    if (normalBricks == 0) {
      newStatus = GameStatus.won;
    }

    return board.copyWith(
      ball: board.ball.copyWith(
        x: newBallX,
        y: newBallY,
        velocityX: newVelocityX,
        velocityY: newVelocityY,
      ),
      paddle: board.paddle.copyWith(x: newPaddleX),
      bricks: newBricks,
      score: newScore,
      highScore: newScore > board.highScore ? newScore : board.highScore,
      lives: newLives,
      status: newStatus,
    );
  }

  static bool _checkBrickCollision(double ballX, double ballY, double ballRadius, Brick brick) {
    // Find closest point to the ball within the brick
    final closestX = (ballX < brick.x)
        ? brick.x
        : (ballX > brick.x + brick.width)
            ? brick.x + brick.width
            : ballX;
    final closestY = (ballY < brick.y)
        ? brick.y
        : (ballY > brick.y + brick.height)
            ? brick.y + brick.height
            : ballY;

    // Calculate distance from closest point
    final distanceX = ballX - closestX;
    final distanceY = ballY - closestY;
    final distance = (distanceX * distanceX + distanceY * distanceY);

    return distance < (ballRadius * ballRadius);
  }

  static BreakoutBoard startGame(BreakoutBoard board) {
    return board.copyWith(status: GameStatus.playing);
  }

  static BreakoutBoard reset(BreakoutBoard board) {
    return BreakoutBoard.initial(board.worldWidth, board.worldHeight).copyWith(
      highScore: board.highScore,
    );
  }

  static BreakoutBoard nextLevel(BreakoutBoard board) {
    return BreakoutBoard.initialLevel(board);
  }
}
