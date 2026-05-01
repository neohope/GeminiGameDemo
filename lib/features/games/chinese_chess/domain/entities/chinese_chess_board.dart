import 'package:equatable/equatable.dart';

typedef Player = String;

const redPlayer = 'red';
const blackPlayer = 'black';

class Piece extends Equatable {
  final String text;
  final Player color;
  final int x;
  final int y;
  final int id;

  const Piece({
    required this.text,
    required this.color,
    required this.x,
    required this.y,
    required this.id,
  });

  Piece copyWith({int? x, int? y}) {
    return Piece(
      text: text,
      color: color,
      x: x ?? this.x,
      y: y ?? this.y,
      id: id,
    );
  }

  @override
  List<Object?> get props => [text, color, x, y, id];
}

class ChineseChessBoard extends Equatable {
  final List<Piece> pieces;
  final Player currentPlayer;

  const ChineseChessBoard({
    required this.pieces,
    required this.currentPlayer,
  });

  factory ChineseChessBoard.initial() {
    final pieces = <Piece>[
      const Piece(text: '車', color: redPlayer, x: 0, y: 0, id: 0),
      const Piece(text: '馬', color: redPlayer, x: 1, y: 0, id: 1),
      const Piece(text: '相', color: redPlayer, x: 2, y: 0, id: 2),
      const Piece(text: '仕', color: redPlayer, x: 3, y: 0, id: 3),
      const Piece(text: '帥', color: redPlayer, x: 4, y: 0, id: 4),
      const Piece(text: '仕', color: redPlayer, x: 5, y: 0, id: 5),
      const Piece(text: '相', color: redPlayer, x: 6, y: 0, id: 6),
      const Piece(text: '馬', color: redPlayer, x: 7, y: 0, id: 7),
      const Piece(text: '車', color: redPlayer, x: 8, y: 0, id: 8),
      const Piece(text: '炮', color: redPlayer, x: 1, y: 2, id: 9),
      const Piece(text: '炮', color: redPlayer, x: 7, y: 2, id: 10),
      const Piece(text: '兵', color: redPlayer, x: 0, y: 3, id: 11),
      const Piece(text: '兵', color: redPlayer, x: 2, y: 3, id: 12),
      const Piece(text: '兵', color: redPlayer, x: 4, y: 3, id: 13),
      const Piece(text: '兵', color: redPlayer, x: 6, y: 3, id: 14),
      const Piece(text: '兵', color: redPlayer, x: 8, y: 3, id: 15),
      const Piece(text: '車', color: blackPlayer, x: 0, y: 9, id: 16),
      const Piece(text: '馬', color: blackPlayer, x: 1, y: 9, id: 17),
      const Piece(text: '象', color: blackPlayer, x: 2, y: 9, id: 18),
      const Piece(text: '士', color: blackPlayer, x: 3, y: 9, id: 19),
      const Piece(text: '將', color: blackPlayer, x: 4, y: 9, id: 20),
      const Piece(text: '士', color: blackPlayer, x: 5, y: 9, id: 21),
      const Piece(text: '象', color: blackPlayer, x: 6, y: 9, id: 22),
      const Piece(text: '馬', color: blackPlayer, x: 7, y: 9, id: 23),
      const Piece(text: '車', color: blackPlayer, x: 8, y: 9, id: 24),
      const Piece(text: '砲', color: blackPlayer, x: 1, y: 7, id: 25),
      const Piece(text: '砲', color: blackPlayer, x: 7, y: 7, id: 26),
      const Piece(text: '卒', color: blackPlayer, x: 0, y: 6, id: 27),
      const Piece(text: '卒', color: blackPlayer, x: 2, y: 6, id: 28),
      const Piece(text: '卒', color: blackPlayer, x: 4, y: 6, id: 29),
      const Piece(text: '卒', color: blackPlayer, x: 6, y: 6, id: 30),
      const Piece(text: '卒', color: blackPlayer, x: 8, y: 6, id: 31),
    ];
    return ChineseChessBoard(pieces: pieces, currentPlayer: redPlayer);
  }

  Piece? getPieceAt(int x, int y) {
    for (final p in pieces) {
      if (p.x == x && p.y == y) return p;
    }
    return null;
  }

  ChineseChessBoard copyWith({
    List<Piece>? pieces,
    Player? currentPlayer,
  }) {
    return ChineseChessBoard(
      pieces: pieces ?? List.from(this.pieces),
      currentPlayer: currentPlayer ?? this.currentPlayer,
    );
  }

  Map<String, dynamic> toJson() {
    final piecesData = pieces.map((p) => {
      'text': p.text,
      'color': p.color,
      'x': p.x,
      'y': p.y,
      'id': p.id,
    }).toList();
    return {
      'pieces': piecesData,
      'currentPlayer': currentPlayer,
    };
  }

  factory ChineseChessBoard.fromJson(Map<String, dynamic> json) {
    final piecesData = json['pieces'] as List<dynamic>;
    final pieces = piecesData.map((data) {
      final map = data as Map<String, dynamic>;
      return Piece(
        text: map['text'] as String,
        color: map['color'] as String,
        x: map['x'] as int,
        y: map['y'] as int,
        id: map['id'] as int,
      );
    }).toList();
    return ChineseChessBoard(
      pieces: pieces,
      currentPlayer: json['currentPlayer'] as Player,
    );
  }

  @override
  List<Object?> get props => [pieces, currentPlayer];
}
