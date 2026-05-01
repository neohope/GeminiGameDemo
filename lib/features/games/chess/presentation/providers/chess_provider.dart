import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/games/chess/domain/entities/chess_board.dart';
import 'package:neo_game_suit/features/games/chess/domain/usecases/chess_logic.dart';
import 'package:neo_game_suit/main.dart';

class ChessState {
  final ChessBoard board;
  final GameMode gameMode;
  final List<ChessBoard> history;
  final (int, int)? selectedPiece;

  ChessState({
    required this.board,
    this.gameMode = GameMode.hvh,
    required this.history,
    this.selectedPiece,
  });

  ChessState copyWith({
    ChessBoard? board,
    GameMode? gameMode,
    List<ChessBoard>? history,
    (int, int)? selectedPiece,
  }) {
    return ChessState(
      board: board ?? this.board,
      gameMode: gameMode ?? this.gameMode,
      history: history ?? this.history,
      selectedPiece: selectedPiece ?? this.selectedPiece,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'gameMode': gameMode.name,
    };
  }

  factory ChessState.fromJson(Map<String, dynamic> json) {
    final board = ChessBoard.fromJson(json['board'] as Map<String, dynamic>);
    final gameMode = GameMode.values.firstWhere((e) => e.name == json['gameMode'], orElse: () => GameMode.hvh);
    return ChessState(
      board: board,
      gameMode: gameMode,
      history: [board],
    );
  }
}

class ChessNotifier extends Notifier<ChessState> {
  static const String _gameId = 'chess';

  @override
  ChessState build() {
    return _loadOrNew();
  }

  ChessState _loadOrNew() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        return ChessState.fromJson(saved);
      } catch (_) {
        // Fall through to new game
      }
    }
    final board = ChessBoard.initial();
    return ChessState(board: board, history: [board]);
  }

  void reset() {
    final board = ChessBoard.initial();
    state = ChessState(board: board, history: [board], gameMode: state.gameMode);
  }

  void setGameMode(GameMode mode) {
    if (state.history.length > 1) return;
    state = state.copyWith(gameMode: mode);
  }

  void selectCell(int row, int col) {
    if (state.selectedPiece != null) {
      final (fromRow, fromCol) = state.selectedPiece!;
      if (ChessLogic.isValidMove(state.board, fromRow, fromCol, row, col)) {
        final newBoard = ChessLogic.makeMove(state.board, fromRow, fromCol, row, col);
        final newHistory = List<ChessBoard>.from(state.history)..add(newBoard);
        state = state.copyWith(board: newBoard, history: newHistory, selectedPiece: null);
        return;
      }
    }
    final piece = state.board.getPiece(row, col);
    if (piece != null && piece.color == state.board.currentPlayer) {
      state = state.copyWith(selectedPiece: (row, col));
    } else {
      state = state.copyWith(selectedPiece: null);
    }
  }

  void undo() {
    if (state.history.length <= 1) return;
    final newHistory = state.history.sublist(0, state.history.length - 1);
    state = state.copyWith(board: newHistory.last, history: newHistory, selectedPiece: null);
  }

  void save() {
    gameStorage.saveGame(_gameId, state.toJson());
  }

  void load() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        state = ChessState.fromJson(saved);
      } catch (_) {
        // Do nothing
      }
    }
  }
}

final chessProvider = NotifierProvider<ChessNotifier, ChessState>(() {
  return ChessNotifier();
});
