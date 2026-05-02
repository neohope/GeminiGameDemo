import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/huarongdao/domain/entities/huarongdao_board.dart';
import 'package:neo_game_suit/features/games/huarongdao/domain/usecases/huarongdao_logic.dart';

class HuarongdaoNotifier extends AutoDisposeNotifier<HuarongdaoBoard> {
  late HuarongdaoLevel _currentLevel;

  @override
  HuarongdaoBoard build() {
    _currentLevel = levels.first;
    return HuarongdaoBoard.initial(_currentLevel);
  }

  void movePiece(Piece piece, int dRow, int dCol) {
    state = HuarongdaoLogic.movePiece(state, piece, dRow, dCol);
  }

  void reset() {
    state = HuarongdaoLogic.reset(_currentLevel);
  }

  void selectLevel(HuarongdaoLevel level) {
    _currentLevel = level;
    state = HuarongdaoLogic.reset(level);
  }
}

final huarongdaoProvider = AutoDisposeNotifierProvider<HuarongdaoNotifier, HuarongdaoBoard>(
  () => HuarongdaoNotifier(),
);
