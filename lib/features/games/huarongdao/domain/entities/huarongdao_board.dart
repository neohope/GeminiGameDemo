enum PieceType {
  caocao, // 2x2 big square
  general, // 1x2 vertical
  soldier, // 1x1 small square
  horizontalGeneral, // 2x1 horizontal
}

class Piece {
  final String id;
  final PieceType type;
  final int row;
  final int col;
  final String name;

  Piece({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    required this.name,
  });

  int get width {
    switch (type) {
      case PieceType.caocao:
        return 2;
      case PieceType.horizontalGeneral:
        return 2;
      case PieceType.general:
      case PieceType.soldier:
        return 1;
    }
  }

  int get height {
    switch (type) {
      case PieceType.caocao:
        return 2;
      case PieceType.general:
        return 2;
      case PieceType.horizontalGeneral:
      case PieceType.soldier:
        return 1;
    }
  }

  Piece copyWith({int? row, int? col}) {
    return Piece(
      id: id,
      type: type,
      row: row ?? this.row,
      col: col ?? this.col,
      name: name,
    );
  }
}

class HuarongdaoLevel {
  final String id;
  final String name;
  final List<Piece> initialPieces;

  HuarongdaoLevel({
    required this.id,
    required this.name,
    required this.initialPieces,
  });
}

// Standard classic levels
final List<HuarongdaoLevel> levels = [
  // 横刀立马
  HuarongdaoLevel(
    id: 'hengdao',
    name: '横刀立马',
    initialPieces: [
      Piece(id: 'caocao', type: PieceType.caocao, row: 0, col: 1, name: '曹操'),
      Piece(id: 'zhangfei', type: PieceType.general, row: 0, col: 0, name: '张飞'),
      Piece(id: 'zhaoyun', type: PieceType.general, row: 0, col: 3, name: '赵云'),
      Piece(id: 'machao', type: PieceType.general, row: 2, col: 0, name: '马超'),
      Piece(id: 'huangzhong', type: PieceType.general, row: 2, col: 3, name: '黄忠'),
      Piece(id: 'guanyu', type: PieceType.horizontalGeneral, row: 2, col: 1, name: '关羽'),
      Piece(id: 'bing1', type: PieceType.soldier, row: 3, col: 0, name: '兵'),
      Piece(id: 'bing2', type: PieceType.soldier, row: 3, col: 1, name: '兵'),
      Piece(id: 'bing3', type: PieceType.soldier, row: 3, col: 2, name: '兵'),
      Piece(id: 'bing4', type: PieceType.soldier, row: 3, col: 3, name: '兵'),
    ],
  ),
  // 指挥若定
  HuarongdaoLevel(
    id: 'zhihui',
    name: '指挥若定',
    initialPieces: [
      Piece(id: 'caocao', type: PieceType.caocao, row: 0, col: 1, name: '曹操'),
      Piece(id: 'zhangfei', type: PieceType.general, row: 0, col: 0, name: '张飞'),
      Piece(id: 'zhaoyun', type: PieceType.general, row: 0, col: 3, name: '赵云'),
      Piece(id: 'guanyu', type: PieceType.horizontalGeneral, row: 2, col: 1, name: '关羽'),
      Piece(id: 'huangzhong', type: PieceType.general, row: 3, col: 0, name: '黄忠'),
      Piece(id: 'machao', type: PieceType.general, row: 3, col: 3, name: '马超'),
      Piece(id: 'bing1', type: PieceType.soldier, row: 2, col: 0, name: '兵'),
      Piece(id: 'bing2', type: PieceType.soldier, row: 2, col: 3, name: '兵'),
      Piece(id: 'bing3', type: PieceType.soldier, row: 4, col: 1, name: '兵'),
      Piece(id: 'bing4', type: PieceType.soldier, row: 4, col: 2, name: '兵'),
    ],
  ),
  // 将拥曹营
  HuarongdaoLevel(
    id: 'jiangyong',
    name: '将拥曹营',
    initialPieces: [
      Piece(id: 'caocao', type: PieceType.caocao, row: 1, col: 1, name: '曹操'),
      Piece(id: 'zhangfei', type: PieceType.general, row: 0, col: 0, name: '张飞'),
      Piece(id: 'zhaoyun', type: PieceType.general, row: 0, col: 3, name: '赵云'),
      Piece(id: 'huangzhong', type: PieceType.general, row: 3, col: 0, name: '黄忠'),
      Piece(id: 'machao', type: PieceType.general, row: 3, col: 3, name: '马超'),
      Piece(id: 'guanyu', type: PieceType.horizontalGeneral, row: 0, col: 1, name: '关羽'),
      Piece(id: 'bing1', type: PieceType.soldier, row: 3, col: 1, name: '兵'),
      Piece(id: 'bing2', type: PieceType.soldier, row: 3, col: 2, name: '兵'),
      Piece(id: 'bing3', type: PieceType.soldier, row: 4, col: 0, name: '兵'),
      Piece(id: 'bing4', type: PieceType.soldier, row: 4, col: 3, name: '兵'),
    ],
  ),
];

class HuarongdaoBoard {
  final List<Piece> pieces;
  final bool isWon;
  final int moveCount;
  final String levelId;

  HuarongdaoBoard({
    required this.pieces,
    required this.isWon,
    required this.moveCount,
    required this.levelId,
  });

  factory HuarongdaoBoard.initial(HuarongdaoLevel level) {
    return HuarongdaoBoard(
      pieces: level.initialPieces.map((p) => p.copyWith()).toList(),
      isWon: false,
      moveCount: 0,
      levelId: level.id,
    );
  }

  HuarongdaoBoard copyWith({
    List<Piece>? pieces,
    bool? isWon,
    int? moveCount,
    String? levelId,
  }) {
    return HuarongdaoBoard(
      pieces: pieces ?? this.pieces,
      isWon: isWon ?? this.isWon,
      moveCount: moveCount ?? this.moveCount,
      levelId: levelId ?? this.levelId,
    );
  }

  Piece? getPieceAt(int row, int col) {
    for (final piece in pieces) {
      if (row >= piece.row &&
          row < piece.row + piece.height &&
          col >= piece.col &&
          col < piece.col + piece.width) {
        return piece;
      }
    }
    return null;
  }
}
