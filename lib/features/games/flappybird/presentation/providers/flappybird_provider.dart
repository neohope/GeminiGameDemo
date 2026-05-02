import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/flappybird/domain/entities/flappybird_board.dart';
import 'package:neo_game_suit/features/games/flappybird/domain/usecases/flappybird_logic.dart';

class FlappyBirdNotifier extends AutoDisposeNotifier<FlappyBirdBoard> {
  Timer? _updateTimer;
  late DifficultySettings _currentDifficulty;
  static const double _defaultWorldWidth = 400;
  static const double _defaultWorldHeight = 600;

  @override
  FlappyBirdBoard build() {
    _currentDifficulty = defaultDifficulties.first;
    ref.onDispose(() {
      _updateTimer?.cancel();
    });
    return FlappyBirdBoard.initial(
      _currentDifficulty,
      _defaultWorldWidth,
      _defaultWorldHeight,
    );
  }

  void jump() {
    state = FlappyBirdLogic.jump(state);
    if (state.status == GameStatus.playing && _updateTimer == null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      state = FlappyBirdLogic.update(state);
      if (state.status == GameStatus.gameOver) {
        timer.cancel();
        _updateTimer = null;
      }
    });
  }

  void reset() {
    _updateTimer?.cancel();
    _updateTimer = null;
    state = FlappyBirdLogic.reset(state);
  }

  void setDifficulty(DifficultySettings settings) {
    _updateTimer?.cancel();
    _updateTimer = null;
    _currentDifficulty = settings;
    state = FlappyBirdLogic.setDifficulty(state, settings);
  }

  void setWorldSize(double width, double height) {
    state = state.copyWith(worldWidth: width, worldHeight: height);
  }
}

final flappyBirdProvider = AutoDisposeNotifierProvider<FlappyBirdNotifier, FlappyBirdBoard>(
  () => FlappyBirdNotifier(),
);
