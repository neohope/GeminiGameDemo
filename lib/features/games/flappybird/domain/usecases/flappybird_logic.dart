import 'dart:math';
import 'package:neo_game_suit/features/games/flappybird/domain/entities/flappybird_board.dart';

class FlappyBirdLogic {
  static final Random _random = Random();

  static FlappyBirdBoard jump(FlappyBirdBoard board) {
    if (board.status == GameStatus.gameOver) return board;
    if (board.status == GameStatus.ready) {
      return startGame(board);
    }
    return board.copyWith(
      bird: board.bird.copyWith(velocity: board.difficulty.jumpForce),
    );
  }

  static FlappyBirdBoard startGame(FlappyBirdBoard board) {
    return board.copyWith(
      status: GameStatus.playing,
      bird: board.bird.copyWith(velocity: board.difficulty.jumpForce),
    );
  }

  static FlappyBirdBoard update(FlappyBirdBoard board) {
    if (board.status != GameStatus.playing) return board;

    // Update bird
    final newBird = board.bird.copyWith(
      y: board.bird.y + board.bird.velocity,
      velocity: board.bird.velocity + board.difficulty.gravity,
    );

    // Check ceiling and floor collision
    final ground = board.worldHeight;
    if (newBird.y < 0 || newBird.y + newBird.size > ground) {
      return gameOver(board);
    }

    // Update pipes
    final newPipes = <Pipe>[];
    int newScore = board.score;
    int newHighScore = board.highScore;
    bool collision = false;
    const birdX = 80.0; // Bird stays at fixed x position

    for (final pipe in board.pipes) {
      final newPipeX = pipe.x - board.difficulty.pipeSpeed;
      if (newPipeX + pipe.width < 0) continue;

      var passed = pipe.passed;
      if (!passed && newPipeX + pipe.width < birdX) {
        passed = true;
        newScore++;
        if (newScore > newHighScore) {
          newHighScore = newScore;
        }
      }

      final updatedPipe = pipe.copyWith(x: newPipeX, passed: passed);
      newPipes.add(updatedPipe);

      // Check collision
      if (!collision && checkCollision(newBird, updatedPipe, birdX)) {
        collision = true;
      }
    }

    if (collision) {
      return gameOver(board.copyWith(
        bird: newBird,
        pipes: newPipes,
        score: newScore,
        highScore: newHighScore,
      ));
    }

    // Spawn new pipe
    if (board.pipes.isEmpty ||
        board.pipes.last.x < board.worldWidth - board.difficulty.pipeSpacing) {
      newPipes.add(_createPipe(board));
    }

    return board.copyWith(
      bird: newBird,
      pipes: newPipes,
      score: newScore,
      highScore: newHighScore,
    );
  }

  static bool checkCollision(Bird bird, Pipe pipe, double birdX) {
    final birdLeft = birdX;
    final birdRight = birdX + bird.size;
    final birdTop = bird.y;
    final birdBottom = bird.y + bird.size;

    final pipeLeft = pipe.x;
    final pipeRight = pipe.x + pipe.width;

    // Check if bird is within pipe's x range
    if (birdRight > pipeLeft && birdLeft < pipeRight) {
      // Check top pipe collision
      if (birdTop < pipe.gapY - pipe.gapSize / 2) {
        return true;
      }
      // Check bottom pipe collision
      if (birdBottom > pipe.gapY + pipe.gapSize / 2) {
        return true;
      }
    }
    return false;
  }

  static FlappyBirdBoard gameOver(FlappyBirdBoard board) {
    return board.copyWith(status: GameStatus.gameOver);
  }

  static FlappyBirdBoard reset(FlappyBirdBoard board) {
    return FlappyBirdBoard.initial(
      board.difficulty,
      board.worldWidth,
      board.worldHeight,
    ).copyWith(highScore: board.highScore);
  }

  static FlappyBirdBoard setDifficulty(FlappyBirdBoard board, DifficultySettings settings) {
    return reset(board.copyWith(difficulty: settings));
  }

  static Pipe _createPipe(FlappyBirdBoard board) {
    final pipeWidth = 80.0;
    final gapY = 100 + _random.nextDouble() * (board.worldHeight - 200);
    return Pipe(
      x: board.worldWidth,
      gapY: gapY,
      gapSize: board.difficulty.gapSize,
      width: pipeWidth,
    );
  }
}
