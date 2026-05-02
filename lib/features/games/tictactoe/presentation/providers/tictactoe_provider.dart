import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/tictactoe/domain/entities/tictactoe_board.dart';
import 'package:neo_game_suit/features/games/tictactoe/domain/usecases/tictactoe_logic.dart';

class TicTacToeNotifier extends AutoDisposeNotifier<TicTacToeBoard> {
  @override
  TicTacToeBoard build() {
    return TicTacToeBoard.initial();
  }

  void makeMove(int row, int col) {
    state = TicTacToeLogic.makeMove(state, row, col);

    // If AI mode, make AI move
    if (state.mode == GameMode.hva && state.status == GameStatus.playing) {
      final aiPlayer = state.humanPlayer == Player.x ? Player.o : Player.x;
      if (state.currentPlayer == aiPlayer) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (state.status == GameStatus.playing) {
            state = TicTacToeLogic.makeAiMove(state);
          }
        });
      }
    }
  }

  void reset({GameMode mode = GameMode.hvh, Player humanPlayer = Player.x}) {
    state = TicTacToeLogic.reset(mode: mode).copyWith(humanPlayer: humanPlayer);
  }
}

final ticTacToeProvider = AutoDisposeNotifierProvider<TicTacToeNotifier, TicTacToeBoard>(
  () => TicTacToeNotifier(),
);
