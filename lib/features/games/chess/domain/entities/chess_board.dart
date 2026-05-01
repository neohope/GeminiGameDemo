import 'package:equatable/equatable.dart';

typedef Player = String;
typedef PieceType = String;

const whitePlayer = 'white';
const blackPlayer = 'black';

const pawn = 'pawn';
const rook = 'rook';
const knight = 'knight';
const bishop = 'bishop';
const queen = 'queen';
const king = 'king';

class Piece extends Equatable {
  final PieceType type;
  final Player color;

  const Piece({required this.type, required this.color});

  @override
  List<Object?> get props => [type, color];
}

class ChessBoard extends Equatable {
  final List<List<Piece?>> board;
  final Player currentPlayer;

  ChessBoard({
    required this.board,
    required this.currentPlayer,
  }) : assert(board.length == 8, 'Board must be 8x8'),
       assert(board.every((row) => row.length == 8), 'Each row must have 8 cells');

  factory ChessBoard.initial() {
    final board = List.generate(8, (_) => List<Piece?>.filled(8, null));

    // Black pieces
    board[0][0] = const Piece(type: rook, color: blackPlayer);
    board[0][1] = const Piece(type: knight, color: blackPlayer);
    board[0][2] = const Piece(type: bishop, color: blackPlayer);
    board[0][3] = const Piece(type: queen, color: blackPlayer);
    board[0][4] = const Piece(type: king, color: blackPlayer);
    board[0][5] = const Piece(type: bishop, color: blackPlayer);
    board[0][6] = const Piece(type: knight, color: blackPlayer);
    board[0][7] = const Piece(type: rook, color: blackPlayer);
    for (int i = 0; i < 8; i++) {
      board[1][i] = const Piece(type: pawn, color: blackPlayer);
    }

    // White pieces
    for (int i = 0; i < 8; i++) {
      board[6][i] = const Piece(type: pawn, color: whitePlayer);
    }
    board[7][0] = const Piece(type: rook, color: whitePlayer);
    board[7][1] = const Piece(type: knight, color: whitePlayer);
    board[7][2] = const Piece(type: bishop, color: whitePlayer);
    board[7][3] = const Piece(type: queen, color: whitePlayer);
    board[7][4] = const Piece(type: king, color: whitePlayer);
    board[7][5] = const Piece(type: bishop, color: whitePlayer);
    board[7][6] = const Piece(type: knight, color: whitePlayer);
    board[7][7] = const Piece(type: rook, color: whitePlayer);

    return ChessBoard(
      board: board,
      currentPlayer: whitePlayer,
    );
  }

  Piece? getPiece(int row, int col) => board[row][col];

  ChessBoard copyWith({
    List<List<Piece?>>? board,
    Player? currentPlayer,
  }) {
    return ChessBoard(
      board: board ?? _copyBoard(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
    );
  }

  static List<List<Piece?>> _copyBoard(List<List<Piece?>> board) {
    return board.map((row) => List<Piece?>.from(row)).toList();
  }

  Map<String, dynamic> toJson() {
    final boardData = board.map((row) =>
      row.map((piece) => piece == null ? null : {'type': piece.type, 'color': piece.color}).toList()
    ).toList();
    return {
      'board': boardData,
      'currentPlayer': currentPlayer,
    };
  }

  factory ChessBoard.fromJson(Map<String, dynamic> json) {
    final boardData = json['board'] as List<dynamic>;
    final parsedBoard = boardData.map((row) =>
      (row as List<dynamic>).map((pieceData) {
        if (pieceData == null) return null;
        final data = pieceData as Map<String, dynamic>;
        return Piece(type: data['type'] as String, color: data['color'] as String);
      }).toList()
    ).toList();
    return ChessBoard(
      board: parsedBoard,
      currentPlayer: json['currentPlayer'] as Player,
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer];
}
