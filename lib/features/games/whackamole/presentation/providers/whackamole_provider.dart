import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/whackamole/domain/entities/whackamole_board.dart';
import 'package:neo_game_suit/features/games/whackamole/domain/usecases/whackamole_logic.dart';

class WhackAMoleNotifier extends AutoDisposeNotifier<WhackAMoleBoard> {
  Timer? _updateTimer;
  late DifficultySettings _currentDifficulty;

  @override
  WhackAMoleBoard build() {
    _currentDifficulty = defaultDifficulties.first;
    ref.onDispose(() {
      _updateTimer?.cancel();
    });
    return WhackAMoleBoard.initial(_currentDifficulty);
  }

  void whackMole(int index) {
    state = WhackAMoleLogic.whackMole(state, index);
  }

  void startGame() {
    state = WhackAMoleLogic.startGame(state);
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      state = WhackAMoleLogic.update(state, DateTime.now());
      if (state.status == GameStatus.finished) {
        timer.cancel();
      }
    });
  }

  void reset() {
    _updateTimer?.cancel();
    state = WhackAMoleLogic.reset(_currentDifficulty);
  }

  void setDifficulty(DifficultySettings settings) {
    _currentDifficulty = settings;
    _updateTimer?.cancel();
    state = WhackAMoleLogic.reset(settings);
  }
}

final whackAMoleProvider = AutoDisposeNotifierProvider<WhackAMoleNotifier, WhackAMoleBoard>(
  () => WhackAMoleNotifier(),
);
