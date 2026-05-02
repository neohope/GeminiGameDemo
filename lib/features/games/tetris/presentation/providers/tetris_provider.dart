import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/tetris/domain/entities/tetris_board.dart';
import 'package:neo_game_suit/features/games/tetris/domain/usecases/tetris_logic.dart';

class TetrisNotifier extends AutoDisposeNotifier<TetrisBoard> {
  Timer? _updateTimer;

  @override
  TetrisBoard build() {
    ref.onDispose(() {
      _updateTimer?.cancel();
    });
    return TetrisBoard.initial(defaultDifficulties.first);
  }

  int _getSpeed() {
    final baseSpeed = state.difficulty.initialSpeed;
    final decrease = (state.level - 1) * state.difficulty.speedIncrease;
    return baseSpeed - decrease;
  }

  void _startTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      Duration(milliseconds: _getSpeed()),
      (timer) {
        if (state.status == GameStatus.playing) {
          state = TetrisLogic.moveDown(state);
        }
      },
    );
  }

  void moveLeft() {
    if (state.status == GameStatus.playing) {
      state = TetrisLogic.moveLeft(state);
    }
  }

  void moveRight() {
    if (state.status == GameStatus.playing) {
      state = TetrisLogic.moveRight(state);
    }
  }

  void moveDown() {
    if (state.status == GameStatus.playing) {
      state = TetrisLogic.moveDown(state);
    }
  }

  void hardDrop() {
    if (state.status == GameStatus.playing) {
      state = TetrisLogic.hardDrop(state);
    }
  }

  void rotate() {
    if (state.status == GameStatus.playing) {
      state = TetrisLogic.rotate(state);
    }
  }

  void startGame() {
    if (state.status == GameStatus.ready || state.status == GameStatus.gameOver) {
      state = TetrisLogic.reset(state.difficulty);
      state = TetrisLogic.startGame(state);
      _startTimer();
    } else if (state.status == GameStatus.paused) {
      togglePause();
    }
  }

  void reset() {
    _updateTimer?.cancel();
    state = TetrisLogic.reset(state.difficulty);
  }

  void togglePause() {
    if (state.status == GameStatus.playing) {
      _updateTimer?.cancel();
      state = TetrisLogic.togglePause(state);
    } else if (state.status == GameStatus.paused) {
      state = TetrisLogic.togglePause(state);
      _startTimer();
    }
  }

  void setDifficulty(DifficultySettings settings) {
    _updateTimer?.cancel();
    state = TetrisLogic.reset(settings);
  }
}

final tetrisProvider = AutoDisposeNotifierProvider<TetrisNotifier, TetrisBoard>(
  () => TetrisNotifier(),
);
