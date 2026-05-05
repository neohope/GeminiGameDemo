import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/fall100/domain/entities/fall100_board.dart';
import 'package:neo_game_suit/features/games/fall100/domain/usecases/fall100_logic.dart';

class Fall100Notifier extends AutoDisposeNotifier<Fall100Board> {
  Timer? _timer;
  double _moveDirection = 0;

  @override
  Fall100Board build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return Fall100Board.initial(400, 600);
  }

  void setWorldSize(double width, double height) {
    if (state.worldWidth != width || state.worldHeight != height) {
      state = Fall100Board.initial(width, height).copyWith(
        highScore: state.highScore,
      );
    }
  }

  void startGame() {
    if (state.status == GameStatus.ready) {
      state = Fall100Logic.startGame(state);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      state = Fall100Logic.update(state, _moveDirection);
      if (state.status == GameStatus.gameOver) {
        _timer?.cancel();
      }
    });
  }

  void moveLeft() {
    _moveDirection = -1;
  }

  void moveRight() {
    _moveDirection = 1;
  }

  void stopMoving() {
    _moveDirection = 0;
  }

  void reset() {
    _timer?.cancel();
    _moveDirection = 0;
    state = Fall100Logic.reset(state);
  }
}

final fall100Provider = AutoDisposeNotifierProvider<Fall100Notifier, Fall100Board>(
  () => Fall100Notifier(),
);
