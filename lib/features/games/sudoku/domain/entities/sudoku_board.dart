import 'package:equatable/equatable.dart';

class SudokuBoard extends Equatable {
  final List<int?> board;
  final List<int?> initialBoard;

  // ignore: prefer_const_constructors_in_immutables
  SudokuBoard({
    required this.board,
    required this.initialBoard,
  }) : assert(board.length == 81, 'Board must have 81 cells'),
       assert(initialBoard.length == 81, 'Initial board must have 81 cells');

  factory SudokuBoard.empty() {
    return SudokuBoard(
      board: List.filled(81, null),
      initialBoard: List.filled(81, null),
    );
  }

  int? getCell(int row, int col) => board[row * 9 + col];
  int? getInitialCell(int row, int col) => initialBoard[row * 9 + col];
  bool isInitialCell(int index) => initialBoard[index] != null;

  SudokuBoard copyWith({
    List<int?>? board,
    List<int?>? initialBoard,
  }) {
    return SudokuBoard(
      board: board ?? List.from(this.board),
      initialBoard: initialBoard ?? List.from(this.initialBoard),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'initialBoard': initialBoard,
    };
  }

  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    return SudokuBoard(
      board: (json['board'] as List<dynamic>).cast<int?>(),
      initialBoard: (json['initialBoard'] as List<dynamic>).cast<int?>(),
    );
  }

  @override
  List<Object?> get props => [board, initialBoard];
}
