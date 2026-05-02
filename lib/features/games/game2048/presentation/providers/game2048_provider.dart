import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/games/game2048/domain/entities/game2048_board.dart';
import 'package:neo_game_suit/features/games/game2048/domain/usecases/game2048_logic.dart';
import 'package:neo_game_suit/main.dart';

class Game2048State {
  final Game2048Board board;
  final List<Game2048Board> history;
  final GameMode gameMode;

  Game2048State({
    required this.board,
    required this.history,
    this.gameMode = GameMode.hvh,
  });

  Game2048State copyWith({
    Game2048Board? board,
    List<Game2048Board>? history,
    GameMode? gameMode,
  }) {
    return Game2048State(
      board: board ?? this.board,
      history: history ?? this.history,
      gameMode: gameMode ?? this.gameMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'gameMode': gameMode.name,
    };
  }

  factory Game2048State.fromJson(Map<String, dynamic> json) {
    return Game2048State(
      board: Game2048Board.fromJson(json['board'] as Map<String, dynamic>),
      history: [],
      gameMode: GameMode.values.firstWhere(
        (e) => e.name == json['gameMode'],
        orElse: () => GameMode.hvh,
      ),
    );
  }
}

class Game2048Notifier extends Notifier<Game2048State> {
  static const String _gameId = 'game2048';

  @override
  Game2048State build() {
    return _loadOrNew();
  }

  Game2048State _loadOrNew() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        return Game2048State.fromJson(saved);
      } catch (_) {
        // Fall through
      }
    }
    return _initialState();
  }

  Game2048State _initialState() {
    final board = Game2048Logic.addInitialTiles(Game2048Board.initial());
    return Game2048State(board: board, history: [board]);
  }

  void reset() {
    state = _initialState();
  }

  void move(MoveDirection direction) {
    if (state.board.gameOver) return;

    final newBoard = Game2048Logic.move(state.board, direction);
    final newHistory = List<Game2048Board>.from(state.history)..add(newBoard);
    state = state.copyWith(board: newBoard, history: newHistory);
  }

  void undo() {
    if (state.history.length <= 1) return;
    final newHistory = state.history.sublist(0, state.history.length - 1);
    state = state.copyWith(board: newHistory.last, history: newHistory);
  }

  void save() {
    gameStorage.saveGame(_gameId, state.toJson());
  }

  void load() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        state = Game2048State.fromJson(saved);
      } catch (_) {
        // Do nothing
      }
    }
  }
}

final game2048Provider = NotifierProvider<Game2048Notifier, Game2048State>(() {
  return Game2048Notifier();
});
