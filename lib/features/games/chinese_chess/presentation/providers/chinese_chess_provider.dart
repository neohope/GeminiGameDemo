import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/usecases/chinese_chess_logic.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/usecases/chinese_chess_ai.dart';
import 'package:neo_game_suit/main.dart';

class ChineseChessState {
  final ChineseChessBoard board;
  final GameMode gameMode;
  final List<ChineseChessBoard> history;
  final Piece? selectedPiece;
  final Player? winner;
  final bool isAiThinking;

  ChineseChessState({
    required this.board,
    this.gameMode = GameMode.hvh,
    required this.history,
    this.selectedPiece,
    this.winner,
    this.isAiThinking = false,
  });

  ChineseChessState copyWith({
    ChineseChessBoard? board,
    GameMode? gameMode,
    List<ChineseChessBoard>? history,
    Piece? selectedPiece,
    Player? winner,
    bool? isAiThinking,
  }) {
    return ChineseChessState(
      board: board ?? this.board,
      gameMode: gameMode ?? this.gameMode,
      history: history ?? this.history,
      selectedPiece: selectedPiece ?? this.selectedPiece,
      winner: winner ?? this.winner,
      isAiThinking: isAiThinking ?? this.isAiThinking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'gameMode': gameMode.name,
    };
  }

  factory ChineseChessState.fromJson(Map<String, dynamic> json) {
    final board = ChineseChessBoard.fromJson(json['board'] as Map<String, dynamic>);
    final gameMode = GameMode.values.firstWhere((e) => e.name == json['gameMode'], orElse: () => GameMode.hvh);
    return ChineseChessState(
      board: board,
      gameMode: gameMode,
      history: [board],
    );
  }
}

class ChineseChessNotifier extends Notifier<ChineseChessState> {
  static const String _gameId = 'chinese_chess';
  Timer? _aiTimer;

  @override
  ChineseChessState build() {
    ref.onDispose(() {
      _aiTimer?.cancel();
    });
    return _loadOrNew();
  }

  ChineseChessState _loadOrNew() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        return ChineseChessState.fromJson(saved);
      } catch (_) {
        // Fall through to new game
      }
    }
    final board = ChineseChessBoard.initial();
    return ChineseChessState(board: board, history: [board]);
  }

  void reset() {
    _aiTimer?.cancel();
    final board = ChineseChessBoard.initial();
    state = ChineseChessState(board: board, history: [board], gameMode: state.gameMode);
  }

  void setGameMode(GameMode mode) {
    if (state.history.length > 1) return;
    state = state.copyWith(gameMode: mode);
  }

  void selectCell(int x, int y) {
    if (state.winner != null || state.isAiThinking) return;

    if (state.gameMode == GameMode.hva && state.board.currentPlayer == blackPlayer) {
      return;
    }

    if (state.selectedPiece != null) {
      if (ChineseChessLogic.isValidMove(state.board, state.selectedPiece!, x, y)) {
        _makeMove(state.selectedPiece!, x, y);
        return;
      }
    }
    final piece = state.board.getPieceAt(x, y);
    if (piece != null && piece.color == state.board.currentPlayer) {
      state = state.copyWith(selectedPiece: piece);
    } else {
      state = state.copyWith(selectedPiece: null);
    }
  }

  void _makeMove(Piece piece, int toX, int toY) {
    final newBoard = ChineseChessLogic.makeMove(state.board, piece, toX, toY);
    final newHistory = List<ChineseChessBoard>.from(state.history)..add(newBoard);
    final winner = ChineseChessLogic.getWinner(newBoard);
    state = state.copyWith(
      board: newBoard,
      history: newHistory,
      selectedPiece: null,
      winner: winner,
    );

    if (winner == null && state.gameMode == GameMode.hva && state.board.currentPlayer == blackPlayer) {
      _scheduleAiMove();
    }
  }

  void _scheduleAiMove() {
    _aiTimer?.cancel();
    state = state.copyWith(isAiThinking: true);
    _aiTimer = Timer(const Duration(milliseconds: 500), () {
      if (!state.isAiThinking || state.winner != null) return;

      final move = ChineseChessAI.findBestMove(state.board, blackPlayer);
      if (move.length == 4) {
        final piece = state.board.getPieceAt(move[0], move[1]);
        if (piece != null) {
          final newBoard = ChineseChessLogic.makeMove(state.board, piece, move[2], move[3]);
          final newHistory = List<ChineseChessBoard>.from(state.history)..add(newBoard);
          final winner = ChineseChessLogic.getWinner(newBoard);
          state = state.copyWith(
            board: newBoard,
            history: newHistory,
            isAiThinking: false,
            winner: winner,
          );
        } else {
          state = state.copyWith(isAiThinking: false);
        }
      } else {
        state = state.copyWith(isAiThinking: false);
      }
    });
  }

  void undo() {
    _aiTimer?.cancel();
    if (state.history.length <= 1) return;

    List<ChineseChessBoard> newHistory;
    if (state.gameMode == GameMode.hva && state.board.currentPlayer == redPlayer && state.history.length > 2) {
      newHistory = state.history.sublist(0, state.history.length - 2);
    } else {
      newHistory = state.history.sublist(0, state.history.length - 1);
    }

    state = state.copyWith(
      board: newHistory.last,
      history: newHistory,
      selectedPiece: null,
      winner: null,
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
        state = ChineseChessState.fromJson(saved);
      } catch (_) {
        // Do nothing
      }
    }
  }
}

final chineseChessProvider = NotifierProvider<ChineseChessNotifier, ChineseChessState>(() {
  return ChineseChessNotifier();
});
