import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/minesweeper/domain/entities/minesweeper_board.dart';
import 'package:neo_game_suit/features/games/minesweeper/domain/usecases/minesweeper_logic.dart';

class MinesweeperNotifier extends AutoDisposeNotifier<MinesweeperBoard> {
  late DifficultySettings _currentDifficulty;

  @override
  MinesweeperBoard build() {
    _currentDifficulty = defaultDifficulties.first;
    return MinesweeperBoard.initial(_currentDifficulty);
  }

  void uncoverCell(int row, int col) {
    state = MinesweeperLogic.uncoverCell(state, row, col);
  }

  void toggleFlag(int row, int col) {
    state = MinesweeperLogic.toggleFlag(state, row, col);
  }

  void reset() {
    state = MinesweeperLogic.reset(_currentDifficulty);
  }

  void setDifficulty(DifficultySettings settings) {
    _currentDifficulty = settings;
    state = MinesweeperLogic.reset(settings);
  }
}

final minesweeperProvider = AutoDisposeNotifierProvider<MinesweeperNotifier, MinesweeperBoard>(
  () => MinesweeperNotifier(),
);
