import 'package:flutter/material.dart';

enum PieceType {
  I, O, T, S, Z, J, L,
}

class Piece {
  final PieceType type;
  final int x;
  final int y;
  final int rotation;

  Piece({
    required this.type,
    required this.x,
    required this.y,
    required this.rotation,
  });

  Piece copyWith({
    PieceType? type,
    int? x,
    int? y,
    int? rotation,
  }) {
    return Piece(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
    );
  }

  List<List<int>> get shape {
    const shapes = <PieceType, List<List<int>>>{
      PieceType.I: [[1, 1, 1, 1]],
      PieceType.O: [[1, 1], [1, 1]],
      PieceType.T: [[0, 1, 0], [1, 1, 1]],
      PieceType.S: [[0, 1, 1], [1, 1, 0]],
      PieceType.Z: [[1, 1, 0], [0, 1, 1]],
      PieceType.J: [[1, 0, 0], [1, 1, 1]],
      PieceType.L: [[0, 0, 1], [1, 1, 1]],
    };
    final shape = shapes[type]!;
    final rotated = _rotateShape(shape, rotation);
    return rotated;
  }

  List<List<int>> _rotateShape(List<List<int>> shape, int times) {
    var current = shape;
    for (int i = 0; i < times % 4; i++) {
      current = _rotateOnce(current);
    }
    return current;
  }

  List<List<int>> _rotateOnce(List<List<int>> shape) {
    final rows = shape.length;
    final cols = shape[0].length;
    final rotated = List.generate(cols, (i) => List<int>.filled(rows, 0));
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        rotated[x][rows - 1 - y] = shape[y][x];
      }
    }
    return rotated;
  }

  Color get color {
    return TetrisBoard.getTypeColor(type);
  }
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class DifficultySettings {
  final Difficulty difficulty;
  final int initialSpeed;
  final int speedIncrease;

  const DifficultySettings({
    required this.difficulty,
    required this.initialSpeed,
    required this.speedIncrease,
  });

  String get name {
    switch (difficulty) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
    }
  }
}

const List<DifficultySettings> defaultDifficulties = [
  DifficultySettings(
    difficulty: Difficulty.easy,
    initialSpeed: 800,
    speedIncrease: 50,
  ),
  DifficultySettings(
    difficulty: Difficulty.medium,
    initialSpeed: 500,
    speedIncrease: 40,
  ),
  DifficultySettings(
    difficulty: Difficulty.hard,
    initialSpeed: 300,
    speedIncrease: 30,
  ),
];

class TetrisBoard {
  static const int cols = 10;
  static const int rows = 20;
  static const int previewRows = 4;
  static const int previewCols = 4;

  final List<List<PieceType?>> board;
  final Piece currentPiece;
  final Piece nextPiece;
  final int score;
  final int highScore;
  final int level;
  final int linesCleared;
  final GameStatus status;
  final DifficultySettings difficulty;

  TetrisBoard({
    required this.board,
    required this.currentPiece,
    required this.nextPiece,
    required this.score,
    required this.highScore,
    required this.level,
    required this.linesCleared,
    required this.status,
    required this.difficulty,
  });

  factory TetrisBoard.initial(DifficultySettings settings) {
    final board = List.generate(rows, (_) => List<PieceType?>.filled(cols, null));
    final firstPiece = createRandomPiece();
    final nextPiece = createRandomPiece();
    return TetrisBoard(
      board: board,
      currentPiece: firstPiece,
      nextPiece: nextPiece,
      score: 0,
      highScore: 0,
      level: 1,
      linesCleared: 0,
      status: GameStatus.ready,
      difficulty: settings,
    );
  }

  static Piece createRandomPiece() {
    final types = PieceType.values;
    final random = DateTime.now().millisecond % types.length;
    final type = types[random];
    final x = (cols / 2 - 1).floor();
    return Piece(type: type, x: x, y: 0, rotation: 0);
  }

  TetrisBoard copyWith({
    List<List<PieceType?>>? board,
    Piece? currentPiece,
    Piece? nextPiece,
    int? score,
    int? highScore,
    int? level,
    int? linesCleared,
    GameStatus? status,
    DifficultySettings? difficulty,
  }) {
    return TetrisBoard(
      board: board ?? deepCopyBoard(this.board),
      currentPiece: currentPiece ?? this.currentPiece,
      nextPiece: nextPiece ?? this.nextPiece,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  static List<List<PieceType?>> deepCopyBoard(List<List<PieceType?>> board) {
    return board.map((row) => List<PieceType?>.from(row)).toList();
  }

  static Color getTypeColor(PieceType type) {
    final colors = <PieceType, Color>{
      PieceType.I: const Color(0xFF00FFFF),
      PieceType.O: const Color(0xFFFFFF00),
      PieceType.T: const Color(0xFF800080),
      PieceType.S: const Color(0xFF00FF00),
      PieceType.Z: const Color(0xFFFF0000),
      PieceType.J: const Color(0xFF0000FF),
      PieceType.L: const Color(0xFFFFA500),
    };
    return colors[type]!;
  }
}

enum GameStatus {
  ready,
  playing,
  paused,
  gameOver,
}
