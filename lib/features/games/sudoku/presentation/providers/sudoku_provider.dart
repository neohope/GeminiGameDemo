import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/features/games/sudoku/domain/entities/sudoku_board.dart';
import 'package:neo_game_suit/features/games/sudoku/domain/usecases/sudoku_logic.dart';
import 'package:neo_game_suit/main.dart';

class SudokuState {
  final SudokuBoard board;
  final int? selectedCell;
  final Set<int> conflictCells;
  final bool isPlayerSolved;
  final bool isAiSolved;

  SudokuState({
    required this.board,
    this.selectedCell,
    this.conflictCells = const {},
    this.isPlayerSolved = false,
    this.isAiSolved = false,
  });

  SudokuState copyWith({
    SudokuBoard? board,
    int? selectedCell,
    Set<int>? conflictCells,
    bool? isPlayerSolved,
    bool? isAiSolved,
  }) {
    return SudokuState(
      board: board ?? this.board,
      selectedCell: selectedCell ?? this.selectedCell,
      conflictCells: conflictCells ?? this.conflictCells,
      isPlayerSolved: isPlayerSolved ?? this.isPlayerSolved,
      isAiSolved: isAiSolved ?? this.isAiSolved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'selectedCell': selectedCell,
      'isAiSolved': isAiSolved,
    };
  }

  factory SudokuState.fromJson(Map<String, dynamic> json) {
    final board = SudokuBoard.fromJson(json['board'] as Map<String, dynamic>);
    final isAiSolved = json['isAiSolved'] as bool? ?? false;
    return SudokuState(
      board: board,
      selectedCell: json['selectedCell'] as int?,
      conflictCells: isAiSolved ? {} : SudokuLogic.findConflicts(board),
      isAiSolved: isAiSolved,
    );
  }
}

class SudokuNotifier extends Notifier<SudokuState> {
  static const String _gameId = 'sudoku';

  @override
  SudokuState build() {
    return _loadOrNew();
  }

  SudokuState _loadOrNew() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        return SudokuState.fromJson(saved);
      } catch (_) {
        // Fall through to new game
      }
    }
    return SudokuState(board: SudokuLogic.generateBoard());
  }

  void newGame() {
    final board = SudokuLogic.generateBoard();
    state = SudokuState(
      board: board,
      conflictCells: const {},
    );
  }

  void reset() {
    state = SudokuState(
      board: state.board.copyWith(board: List.from(state.board.initialBoard)),
      conflictCells: const {},
    );
  }

  void selectCell(int index) {
    if (state.isAiSolved) return;
    if (state.board.isInitialCell(index)) return;
    state = state.copyWith(selectedCell: index);
  }

  void setCellValue(int? value) {
    if (state.selectedCell == null || state.isAiSolved) return;
    final newBoard = List<int?>.from(state.board.board);
    newBoard[state.selectedCell!] = value;
    final board = state.board.copyWith(board: newBoard);
    final conflicts = SudokuLogic.findConflicts(board);
    final solved = SudokuLogic.isSolved(board);
    state = state.copyWith(
      board: board,
      conflictCells: conflicts,
      isPlayerSolved: solved,
    );
  }

  void solve() {
    final board = SudokuBoard(
      board: List.from(state.board.initialBoard),
      initialBoard: List.from(state.board.initialBoard),
    );
    SudokuLogic.solveSudoku(board);
    state = state.copyWith(
      board: board,
      isAiSolved: true,
      conflictCells: const {},
      isPlayerSolved: false,
    );
  }

  void save() {
    gameStorage.saveGame(_gameId, state.toJson());
  }

  void load() {
    final saved = gameStorage.loadGame(_gameId);
    if (saved != null) {
      try {
        state = SudokuState.fromJson(saved);
      } catch (_) {
        // Do nothing
      }
    }
  }
}

final sudokuProvider = NotifierProvider<SudokuNotifier, SudokuState>(() {
  return SudokuNotifier();
});
