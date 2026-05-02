import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/reversi/domain/entities/reversi_board.dart';
import 'package:neo_game_suit/features/games/reversi/domain/usecases/reversi_logic.dart';

class ReversiNotifier extends AutoDisposeNotifier<ReversiBoard> {
  @override
  ReversiBoard build() {
    return ReversiBoard.initial();
  }

  void makeMove(int row, int col) {
    state = ReversiLogic.makeMove(state, row, col);

    // If AI mode, make AI move
    if (state.mode == GameMode.hva && state.status == GameStatus.playing) {
      final aiPlayer = state.humanPlayer == Player.black ? Player.white : Player.black;
      if (state.currentPlayer == aiPlayer) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (state.status == GameStatus.playing && state.currentPlayer == aiPlayer) {
            state = ReversiLogic.makeAiMove(state);
          }
        });
      }
    }
  }

  void reset({GameMode mode = GameMode.hvh, Player humanPlayer = Player.black}) {
    state = ReversiLogic.reset(mode: mode).copyWith(humanPlayer: humanPlayer);
  }
}

final reversiProvider = AutoDisposeNotifierProvider<ReversiNotifier, ReversiBoard>(
  () => ReversiNotifier(),
);
