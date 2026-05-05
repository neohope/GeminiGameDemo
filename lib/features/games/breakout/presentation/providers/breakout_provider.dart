import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/breakout/domain/entities/breakout_board.dart';
import 'package:neo_game_suit/features/games/breakout/domain/usecases/breakout_logic.dart';

class BreakoutNotifier extends AutoDisposeNotifier<BreakoutBoard> {
  Timer? _timer;
  double _targetPaddleX = 0;

  @override
  BreakoutBoard build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return BreakoutBoard.initial(600, 800);
  }

  void setWorldSize(double width, double height) {
    if (state.worldWidth != width || state.worldHeight != height) {
      state = BreakoutBoard.initial(width, height).copyWith(
        highScore: state.highScore,
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

  void movePaddleLeft() {
    _targetPaddleX -= 10;
  }

  void movePaddleRight() {
    _targetPaddleX += 10;
  }

  void reset() {
    _timer?.cancel();
    state = BreakoutLogic.reset(state);
    _targetPaddleX = state.paddle.x;
  }

  void nextLevel() {
    _timer?.cancel();
    state = BreakoutLogic.nextLevel(state);
    _targetPaddleX = state.paddle.x;
  }
}

final breakoutProvider = AutoDisposeNotifierProvider<BreakoutNotifier, BreakoutBoard>(
  () => BreakoutNotifier(),
);
