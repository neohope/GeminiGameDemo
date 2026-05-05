import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/dino/domain/entities/dino_board.dart';
import 'package:neo_game_suit/features/games/dino/domain/usecases/dino_logic.dart';

class DinoNotifier extends AutoDisposeNotifier<DinoBoard> {
  Timer? _timer;

  @override
  DinoBoard build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return DinoBoard.initial(800, 400);
  }

  void setWorldSize(double width, double height) {
    if (state.worldWidth != width || state.worldHeight != height) {
      state = DinoBoard.initial(width, height).copyWith(
        highScore: state.highScore,
      );
    }
  }

  void startGame() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      state = DinoLogic.update(state);
    });
  }

  void jump() {
    if (state.status == GameStatus.ready) {
      state = DinoLogic.jump(state);
      startGame();
    } else {
      state = DinoLogic.jump(state);
    }
  }

  void duck(bool isDucking) {
    state = DinoLogic.duck(state, isDucking);
  }

  void reset() {
    _timer?.cancel();
    state = DinoLogic.reset(state);
  }
}

final dinoProvider = AutoDisposeNotifierProvider<DinoNotifier, DinoBoard>(
  () => DinoNotifier(),
);
