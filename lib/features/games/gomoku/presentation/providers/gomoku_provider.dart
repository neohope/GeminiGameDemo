import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/games/gomoku/domain/entities/gomoku_board.dart';
import 'package:neo_game_suit/features/games/gomoku/domain/usecases/gomoku_logic.dart';
import 'package:neo_game_suit/features/games/gomoku/domain/usecases/gomoku_ai.dart';
import 'package:neo_game_suit/main.dart';

class GomokuState {
  final GomokuBoard board;
  final Player? winner;
  final GameMode gameMode;
  final List<GomokuBoard> history;
  final bool isAiThinking;

  GomokuState({
    required this.board,
    this.winner,
    this.gameMode = GameMode.hvh,
    required this.history,
    this.isAiThinking = false,
  });

  GomokuState copyWith({
    GomokuBoard? board,
    Player? winner,
    GameMode? gameMode,
    List<GomokuBoard>? history,
    bool? isAiThinking,
  }) {
    return GomokuState(
      board: board ?? this.board,
      winner: winner ?? this.winner,
      gameMode: gameMode ?? this.gameMode,
      history: history ?? this.history,
      isAiThinking: isAiThinking ?? this.isAiThinking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'winner': winner,
      'gameMode': gameMode.name,
    };
  }

  factory GomokuState.fromJson(Map<String, dynamic> json) {
    final board = GomokuBoard.fromJson(json['board'] as Map<String, dynamic>);
    final gameMode = GameMode.values.firstWhere((e) => e.name == json['gameMode'], orElse: () => GameMode.hvh);
    return GomokuState(
      board: board,
      winner: json['winner'] as Player?,
      gameMode: gameMode,
      history: [board],
    );
  }
}

class GomokuNotifier extends Notifier<GomokuState> {
  static const String _gameId = 'gomoku';
  Timer? _aiTimer;

  @override
  GomokuState build() {
    ref.onDispose(() {
      _aiTimer?.cancel();
    });
    return _loadOrNew();
  }

  GomokuState _loadOrNew() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        return GomokuState.fromJson(saved);
      } catch (_) {
        // Fall through to new game
      }
    }
    final board = GomokuBoard.empty();
    return GomokuState(board: board, history: [board]);
  }

  void reset() {
    _aiTimer?.cancel();
    final board = GomokuBoard.empty();
    state = GomokuState(board: board, history: [board], gameMode: state.gameMode);
  }

  void setGameMode(GameMode mode) {
    if (state.history.length > 1) return;
    state = state.copyWith(gameMode: mode);
  }

  void makeMove(int row, int col) {
    if (state.winner != null || state.isAiThinking) return;
    if (state.gameMode == GameMode.hva && state.board.currentPlayer == whitePlayer) {
      return;
    }
    if (!GomokuLogic.isValidMove(state.board, row, col)) return;

    final newBoard = _copyBoard(state.board.board);
    newBoard[row][col] = state.board.currentPlayer;
    final boardState = GomokuBoard(
      board: newBoard,
      currentPlayer: state.board.currentPlayer == blackPlayer ? whitePlayer : blackPlayer,
    );

    Player? winner;
    if (GomokuLogic.checkWin(boardState, row, col, state.board.currentPlayer)) {
      winner = state.board.currentPlayer;
    }

    final newHistory = List<GomokuBoard>.from(state.history)..add(boardState);
    state = state.copyWith(
      board: boardState,
      winner: winner,
      history: newHistory,
    );

    if (winner == null && state.gameMode == GameMode.hva && state.board.currentPlayer == whitePlayer) {
      _scheduleAiMove();
    }
  }

  void _scheduleAiMove() {
    _aiTimer?.cancel();
    state = state.copyWith(isAiThinking: true);
    _aiTimer = Timer(const Duration(milliseconds: 300), () {
      if (!state.isAiThinking || state.winner != null) return;
      final move = GomokuAI.findBestMove(state.board, whitePlayer);
      final newBoard = _copyBoard(state.board.board);
      newBoard[move[0]][move[1]] = whitePlayer;
      final boardState = GomokuBoard(
        board: newBoard,
        currentPlayer: blackPlayer,
      );
      Player? winner;
      if (GomokuLogic.checkWin(boardState, move[0], move[1], whitePlayer)) {
        winner = whitePlayer;
      }
      final newHistory = List<GomokuBoard>.from(state.history)..add(boardState);
      state = state.copyWith(
        board: boardState,
        winner: winner,
        history: newHistory,
        isAiThinking: false,
      );
    });
  }

  void undo() {
    _aiTimer?.cancel();
    if (state.history.length <= 1 || state.winner != null) return;

    List<GomokuBoard> newHistory;
    if (state.gameMode == GameMode.hva && state.board.currentPlayer == blackPlayer && state.history.length > 2) {
      newHistory = state.history.sublist(0, state.history.length - 2);
    } else {
      newHistory = state.history.sublist(0, state.history.length - 1);
    }

    state = state.copyWith(
      board: newHistory.last,
      history: newHistory,
      isAiThinking: false,
    );
  }

  void save() {
    gameStorage.saveGame(_gameId, state.toJson());
  }

  void load() {
    _aiTimer?.cancel();
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        state = GomokuState.fromJson(saved);
      } catch (_) {
        // Do nothing
      }
    }
  }

  List<List<Player?>> _copyBoard(List<List<Player?>> board) {
    return board.map((row) => List<Player?>.from(row)).toList();
  }
}

final gomokuProvider = NotifierProvider<GomokuNotifier, GomokuState>(() {
  return GomokuNotifier();
});
