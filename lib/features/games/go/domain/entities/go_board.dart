import 'package:equatable/equatable.dart';

typedef Player = String;

const blackPlayer = 'black';
const whitePlayer = 'white';

const boardSize = 19;

class GoBoard extends Equatable {
  final List<List<Player?>> board;
  final Player currentPlayer;
  final int blackCaptures;
  final int whiteCaptures;
  final bool lastPass;
  final (int, int)? koPoint;

  GoBoard({
    required this.board,
    required this.currentPlayer,
    required this.blackCaptures,
    required this.whiteCaptures,
    required this.lastPass,
    this.koPoint,
  }) : assert(board.length == boardSize, 'Board must be 19x19'),
       assert(board.every((row) => row.length == boardSize), 'Each row must have 19 cells');

  factory GoBoard.initial() {
    final board = List.generate(boardSize, (_) => List<Player?>.filled(boardSize, null));
    return GoBoard(
      board: board,
      currentPlayer: blackPlayer,
      blackCaptures: 0,
      whiteCaptures: 0,
      lastPass: false,
    );
  }

  Player? getPiece(int row, int col) => board[row][col];

  GoBoard copyWith({
    List<List<Player?>>? board,
    Player? currentPlayer,
    int? blackCaptures,
    int? whiteCaptures,
    bool? lastPass,
    (int, int)? koPoint,
  }) {
    return GoBoard(
      board: board ?? _copyBoard(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      blackCaptures: blackCaptures ?? this.blackCaptures,
      whiteCaptures: whiteCaptures ?? this.whiteCaptures,
      lastPass: lastPass ?? this.lastPass,
      koPoint: koPoint,
    );
  }

  static List<List<Player?>> _copyBoard(List<List<Player?>> board) {
    return board.map((row) => List<Player?>.from(row)).toList();
  }

  Map<String, dynamic> toJson() {
    final boardData = board.map((row) => row.toList()).toList();
    return {
      'board': boardData,
      'currentPlayer': currentPlayer,
      'blackCaptures': blackCaptures,
      'whiteCaptures': whiteCaptures,
      'lastPass': lastPass,
      'koPointRow': koPoint?.$1,
      'koPointCol': koPoint?.$2,
    };
  }

  factory GoBoard.fromJson(Map<String, dynamic> json) {
    final boardData = json['board'] as List<dynamic>;
    final parsedBoard = boardData.map((row) =>
      (row as List<dynamic>).map((cell) => cell as Player?).toList()
    ).toList();
    final koPointRow = json['koPointRow'] as int?;
    final koPointCol = json['koPointCol'] as int?;
    return GoBoard(
      board: parsedBoard,
      currentPlayer: json['currentPlayer'] as Player,
      blackCaptures: json['blackCaptures'] as int,
      whiteCaptures: json['whiteCaptures'] as int,
      lastPass: json['lastPass'] as bool,
      koPoint: koPointRow != null && koPointCol != null ? (koPointRow, koPointCol) : null,
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer, blackCaptures, whiteCaptures, lastPass, koPoint];
}
