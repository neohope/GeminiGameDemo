import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/reversi/domain/entities/reversi_board.dart';
import 'package:neo_game_suit/features/games/reversi/domain/usecases/reversi_logic.dart';

class ReversiNotifier extends AutoDisposeNotifier<ReversiBoard> {
  @override
  ReversiBoard build() {
    return ReversiBoard.initial();
  }

  bool get hasGameStarted {
    int filledCount = 0;
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (state.board[row][col] != Player.none) {
          filledCount++;
        }
      }
    }
    return filledCount > 4; // initial position has 4 filled
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
    final newBoard = ReversiLogic.reset(mode: mode).copyWith(humanPlayer: humanPlayer);
    state = newBoard;

    // If AI plays first
    if (mode == GameMode.hva && humanPlayer == Player.white) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (state.status == GameStatus.playing) {
          state = ReversiLogic.makeAiMove(state);
        }
      });
    }
  }

  void setModeAndPlayer(GameMode mode, Player humanPlayer) {
    reset(mode: mode, humanPlayer: humanPlayer);
  }
}

final reversiProvider = AutoDisposeNotifierProvider<ReversiNotifier, ReversiBoard>(
  () => ReversiNotifier(),
);
