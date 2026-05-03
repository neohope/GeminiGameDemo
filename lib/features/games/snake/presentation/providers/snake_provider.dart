import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/snake/domain/entities/snake_board.dart';
import 'package:neo_game_suit/features/games/snake/domain/usecases/snake_logic.dart';

class SnakeNotifier extends AutoDisposeNotifier<SnakeBoard> {
  Timer? _timer;

  @override
  SnakeBoard build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return SnakeBoard.initial();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: state.speed), (_) {
      move();
    });
  }

  void move() {
    final updated = SnakeLogic.move(state);
    if (updated.isGameOver) {
      _timer?.cancel();
    }
    state = updated;
  }

  void changeDirection(Direction direction) {
    state = SnakeLogic.changeDirection(state, direction);
  }

  void reset() {
    _timer?.cancel();
    state = SnakeLogic.reset();
  }

  void start() {
    state = state.copyWith(isPaused: false);
    _startTimer();
  }

  void togglePause() {
    final updated = SnakeLogic.togglePause(state);
    if (updated.isPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    state = updated;
  }
}

final snakeProvider = AutoDisposeNotifierProvider<SnakeNotifier, SnakeBoard>(
  () => SnakeNotifier(),
);
