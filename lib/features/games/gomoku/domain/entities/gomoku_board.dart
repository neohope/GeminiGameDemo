import 'package:equatable/equatable.dart';

typedef Player = String;

const blackPlayer = 'black';
const whitePlayer = 'white';

const boardSize = 15;

class GomokuBoard extends Equatable {
  final List<List<Player?>> board;
  final Player currentPlayer;

  GomokuBoard({
    required this.board,
    required this.currentPlayer,
  }) : assert(board.length == boardSize, 'Board must be 15x15'),
       assert(board.every((row) => row.length == boardSize),
       'Each row must have 15 cells');

  factory GomokuBoard.empty() {
    final board = List.generate(boardSize, (_) => List<Player?>.filled(boardSize, null));
    return GomokuBoard(
      board: board,
      currentPlayer: blackPlayer,
    );
  }

  Player? getCell(int row, int col) => board[row][col];

  GomokuBoard copyWith({
    List<List<Player?>>? board,
    Player? currentPlayer,
  }) {
    return GomokuBoard(
      board: board ?? _copyBoard(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
    );
  }

  static List<List<Player?>> _copyBoard(List<List<Player?>> board) {
    return board.map((row) => List<Player?>.from(row)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.map((row) => row.toList()).toList(),
      'currentPlayer': currentPlayer,
    };
  }

  factory GomokuBoard.fromJson(Map<String, dynamic> json) {
    final boardData = json['board'] as List<dynamic>;
    final parsedBoard = boardData.map((row) => (row as List<dynamic>).map((cell) => cell as Player?).toList()).toList();
    return GomokuBoard(
      board: parsedBoard,
      currentPlayer: json['currentPlayer'] as Player,
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer];
}
