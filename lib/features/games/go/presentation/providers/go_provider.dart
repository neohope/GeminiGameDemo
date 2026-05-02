import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/games/go/domain/entities/go_board.dart';
import 'package:neo_game_suit/features/games/go/domain/usecases/go_logic.dart';
import 'package:neo_game_suit/main.dart';

class GoState {
  final GoBoard board;
  final GameMode gameMode;
  final List<GoBoard> history;
  final bool gameOver;

  GoState({
    required this.board,
    this.gameMode = GameMode.hvh,
    required this.history,
    this.gameOver = false,
  });

  GoState copyWith({
    GoBoard? board,
    GameMode? gameMode,
    List<GoBoard>? history,
    bool? gameOver,
  }) {
    return GoState(
      board: board ?? this.board,
      gameMode: gameMode ?? this.gameMode,
      history: history ?? this.history,
      gameOver: gameOver ?? this.gameOver,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'gameMode': gameMode.name,
    };
  }

  factory GoState.fromJson(Map<String, dynamic> json) {
    final board = GoBoard.fromJson(json['board'] as Map<String, dynamic>);
    final gameMode = GameMode.values.firstWhere((e) => e.name == json['gameMode'], orElse: () => GameMode.hvh);
    return GoState(
      board: board,
      gameMode: gameMode,
      history: [board],
    );
  }
}

class GoNotifier extends Notifier<GoState> {
  static const String _gameId = 'go';

  @override
  GoState build() {
    return _loadOrNew();
  }

  GoState _loadOrNew() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        return GoState.fromJson(saved);
      } catch (_) {
        // Fall through to new game
      }
    }
    final board = GoBoard.initial();
    return GoState(board: board, history: [board]);
  }

  void reset() {
    final board = GoBoard.initial();
    state = GoState(board: board, history: [board], gameMode: state.gameMode);
  }

  void setGameMode(GameMode mode) {
    if (state.history.length > 1) return;
    state = state.copyWith(gameMode: mode);
  }

  void makeMove(int row, int col) {
    if (state.gameOver) return;
    if (!GoLogic.isValidMove(state.board, row, col)) return;

    final newBoard = GoLogic.makeMove(state.board, row, col);
    if (newBoard == null) return;

    final newHistory = List<GoBoard>.from(state.history)..add(newBoard);
    state = state.copyWith(board: newBoard, history: newHistory);
  }

  void pass() {
    if (state.gameOver) return;
    if (state.board.lastPass) {
      state = state.copyWith(gameOver: true);
    } else {
      final newBoard = GoLogic.pass(state.board);
      final newHistory = List<GoBoard>.from(state.history)..add(newBoard);
      state = state.copyWith(board: newBoard, history: newHistory);
    }
  }

  void undo() {
    if (state.history.length <= 1) return;
    final newHistory = state.history.sublist(0, state.history.length - 1);
    state = state.copyWith(board: newHistory.last, history: newHistory, gameOver: false);
  }

  void save() {
    gameStorage.saveGame(_gameId, state.toJson());
  }

  void load() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        state = GoState.fromJson(saved);
      } catch (_) {
        // Do nothing
      }
    }
  }
}

final goProvider = NotifierProvider<GoNotifier, GoState>(() {
  return GoNotifier();
});
