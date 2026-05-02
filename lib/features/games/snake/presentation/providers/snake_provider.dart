import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/snake/domain/entities/snake_board.dart';
import 'package:neo_game_suit/features/games/snake/domain/usecases/snake_logic.dart';

class SnakeNotifier extends AutoDisposeAsyncNotifier<SnakeBoard> {
  Timer? _timer;

  @override
  Future<SnakeBoard> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return SnakeBoard.initial();
  }

  void _startTimer() {
    _timer?.cancel();
    final current = state.value;
    if (current == null) return;
    _timer = Timer.periodic(Duration(milliseconds: current.speed), (_) {
      move();
    });
  }

  void move() {
    state = state.whenData((board) {
      final updated = SnakeLogic.move(board);
      if (updated.isGameOver) {
        _timer?.cancel();
      }
      return updated;
    });
  }

  void changeDirection(Direction direction) {
    state = state.whenData((board) {
      return SnakeLogic.changeDirection(board, direction);
    });
  }

  void reset() {
    _timer?.cancel();
    state = AsyncData(SnakeLogic.reset());
  }

  void start() {
    state = state.whenData((board) => board.copyWith(isPaused: false));
    _startTimer();
  }

  void togglePause() {
    state = state.whenData((board) {
      final updated = SnakeLogic.togglePause(board);
      if (updated.isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
      return updated;
    });
  }
}

final snakeProvider = AutoDisposeAsyncNotifierProvider<SnakeNotifier, SnakeBoard>(
  () => SnakeNotifier(),
);
