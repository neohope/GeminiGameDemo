class Bird {
  final double y;
  final double velocity;
  final double size;

  Bird({
    required this.y,
    required this.velocity,
    required this.size,
  });

  Bird copyWith({
    double? y,
    double? velocity,
    double? size,
  }) {
    return Bird(
      y: y ?? this.y,
      velocity: velocity ?? this.velocity,
      size: size ?? this.size,
    );
  }
}

class Pipe {
  final double x;
  final double gapY;
  final double gapSize;
  final double width;
  final bool passed;

  Pipe({
    required this.x,
    required this.gapY,
    required this.gapSize,
    required this.width,
    this.passed = false,
  });

  Pipe copyWith({
    double? x,
    double? gapY,
    double? gapSize,
    double? width,
    bool? passed,
  }) {
    return Pipe(
      x: x ?? this.x,
      gapY: gapY ?? this.gapY,
      gapSize: gapSize ?? this.gapSize,
      width: width ?? this.width,
      passed: passed ?? this.passed,
    );
  }
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class DifficultySettings {
  final Difficulty difficulty;
  final double gravity;
  final double jumpForce;
  final double pipeSpeed;
  final double pipeSpacing;
  final double gapSize;

  const DifficultySettings({
    required this.difficulty,
    required this.gravity,
    required this.jumpForce,
    required this.pipeSpeed,
    required this.pipeSpacing,
    required this.gapSize,
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
    gravity: 0.4,
    jumpForce: -7.0, // Less sensitive
    pipeSpeed: 3.5,
    pipeSpacing: 280,
    gapSize: 180,
  ),
  DifficultySettings(
    difficulty: Difficulty.medium,
    gravity: 0.5,
    jumpForce: -7.5, // Less sensitive
    pipeSpeed: 4.5,
    pipeSpacing: 240,
    gapSize: 150,
  ),
  DifficultySettings(
    difficulty: Difficulty.hard,
    gravity: 0.6,
    jumpForce: -8.0, // Less sensitive
    pipeSpeed: 5.5,
    pipeSpacing: 200,
    gapSize: 120,
  ),
];

class FlappyBirdBoard {
  final Bird bird;
  final List<Pipe> pipes;
  final int score;
  final int highScore;
  final GameStatus status;
  final DifficultySettings difficulty;
  final double worldHeight;
  final double worldWidth;

  FlappyBirdBoard({
    required this.bird,
    required this.pipes,
    required this.score,
    required this.highScore,
    required this.status,
    required this.difficulty,
    required this.worldHeight,
    required this.worldWidth,
  });

  factory FlappyBirdBoard.initial(DifficultySettings settings, double worldWidth, double worldHeight) {
    return FlappyBirdBoard(
      bird: Bird(
        y: worldHeight / 2,
        velocity: 0,
        size: 40,
      ),
      pipes: [],
      score: 0,
      highScore: 0,
      status: GameStatus.ready,
      difficulty: settings,
      worldWidth: worldWidth,
      worldHeight: worldHeight,
    );
  }

  FlappyBirdBoard copyWith({
    Bird? bird,
    List<Pipe>? pipes,
    int? score,
    int? highScore,
    GameStatus? status,
    DifficultySettings? difficulty,
    double? worldHeight,
    double? worldWidth,
  }) {
    return FlappyBirdBoard(
      bird: bird ?? this.bird,
      pipes: pipes ?? this.pipes,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      worldHeight: worldHeight ?? this.worldHeight,
      worldWidth: worldWidth ?? this.worldWidth,
    );
  }
}

enum GameStatus {
  ready,
  playing,
  gameOver,
}
