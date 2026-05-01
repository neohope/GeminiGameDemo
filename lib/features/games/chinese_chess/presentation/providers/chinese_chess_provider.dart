import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/usecases/chinese_chess_logic.dart';
import 'package:neo_game_suit/main.dart';

class ChineseChessState {
  final ChineseChessBoard board;
  final GameMode gameMode;
  final List<ChineseChessBoard> history;
  final Piece? selectedPiece;

  ChineseChessState({
    required this.board,
    this.gameMode = GameMode.hvh,
    required this.history,
    this.selectedPiece,
  });

  ChineseChessState copyWith({
    ChineseChessBoard? board,
    GameMode? gameMode,
    List<ChineseChessBoard>? history,
    Piece? selectedPiece,
  }) {
    return ChineseChessState(
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

  @override
  ChineseChessState build() {
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
    final board = ChineseChessBoard.initial();
    state = ChineseChessState(board: board, history: [board], gameMode: state.gameMode);
  }

  void setGameMode(GameMode mode) {
    if (state.history.length > 1) return;
    state = state.copyWith(gameMode: mode);
  }

  void selectCell(int x, int y) {
    if (state.selectedPiece != null) {
      if (ChineseChessLogic.isValidMove(state.board, state.selectedPiece!, x, y)) {
        final newBoard = ChineseChessLogic.makeMove(state.board, state.selectedPiece!, x, y);
        final newHistory = List<ChineseChessBoard>.from(state.history)..add(newBoard);
        state = state.copyWith(board: newBoard, history: newHistory, selectedPiece: null);
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
