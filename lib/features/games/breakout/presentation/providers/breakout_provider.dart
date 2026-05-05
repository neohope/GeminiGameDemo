import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/breakout/domain/entities/breakout_board.dart';
import 'package:neo_game_suit/features/games/breakout/domain/usecases/breakout_logic.dart';

class BreakoutNotifier extends AutoDisposeNotifier<BreakoutBoard> {
  Timer? _timer;
  double _targetPaddleX = 0;
  double _keyboardMoveDirection = 0;
  double _worldWidth = 600;
  double _worldHeight = 800;

  @override
  BreakoutBoard build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return BreakoutBoard.initial(_worldWidth, _worldHeight);
  }

  void setWorldSize(double width, double height) {
    if (_worldWidth != width || _worldHeight != height) {
      _worldWidth = width;
      _worldHeight = height;
      final currentHighScore = state.highScore;
      state = BreakoutBoard.initial(width, height).copyWith(
        highScore: currentHighScore,
      );
      _targetPaddleX = state.paddle.x;
    }
  }

  void startGame() {
    if (state.status == GameStatus.ready) {
      state = BreakoutLogic.startGame(state);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      // Apply keyboard movement
      if (_keyboardMoveDirection != 0) {
        _targetPaddleX += _keyboardMoveDirection * 12;
      }

      // Smooth paddle movement
      final diff = _targetPaddleX - state.paddle.x;
      final newPaddleX = state.paddle.x + diff * 0.3;

      state = BreakoutLogic.update(state, newPaddleX);

      if (state.status == GameStatus.gameOver || state.status == GameStatus.won) {
        _timer?.cancel();
      }
    });
  }

  void setPaddlePosition(double x) {
    _targetPaddleX = x - state.paddle.width / 2;
  }

  void setKeyboardMoveDirection(double direction) {
    _keyboardMoveDirection = direction;
  }

  void reset() {
    _timer?.cancel();
    _keyboardMoveDirection = 0;
    final currentHighScore = state.highScore;
    state = BreakoutBoard.initial(_worldWidth, _worldHeight).copyWith(
      highScore: currentHighScore,
    );
    _targetPaddleX = state.paddle.x;
  }

  void nextLevel() {
    _timer?.cancel();
    _keyboardMoveDirection = 0;
    final currentHighScore = state.highScore;
    final currentScore = state.score;
    state = BreakoutBoard.initial(_worldWidth, _worldHeight).copyWith(
      score: currentScore,
      highScore: currentHighScore,
      level: state.level + 1,
    );
    _targetPaddleX = state.paddle.x;
  }
}

final breakoutProvider = AutoDisposeNotifierProvider<BreakoutNotifier, BreakoutBoard>(
  () => BreakoutNotifier(),
);
