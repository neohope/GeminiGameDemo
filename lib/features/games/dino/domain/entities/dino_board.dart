class Dino {
  final double y;
  final double velocity;
  final double size;
  final bool isDucking;

  Dino({
    required this.y,
    required this.velocity,
    required this.size,
    this.isDucking = false,
  });

  Dino copyWith({
    double? y,
    double? velocity,
    double? size,
    bool? isDucking,
  }) {
    return Dino(
      y: y ?? this.y,
      velocity: velocity ?? this.velocity,
      size: size ?? this.size,
      isDucking: isDucking ?? this.isDucking,
    );
  }
}

class Obstacle {
  final double x;
  final double width;
  final double height;
  final double y;
  final ObstacleType type;
  final bool passed;

  Obstacle({
    required this.x,
    required this.width,
    required this.height,
    required this.y,
    required this.type,
    this.passed = false,
  });

  Obstacle copyWith({
    double? x,
    double? width,
    double? height,
    double? y,
    ObstacleType? type,
    bool? passed,
  }) {
    return Obstacle(
      x: x ?? this.x,
      width: width ?? this.width,
      height: height ?? this.height,
      y: y ?? this.y,
      type: type ?? this.type,
      passed: passed ?? this.passed,
    );
  }
}

enum ObstacleType {
  smallCactus,
  largeCactus,
  bird,
}

class Cloud {
  final double x;
  final double y;
  final double size;

  Cloud({
    required this.x,
    required this.y,
    required this.size,
  });

  Cloud copyWith({
    double? x,
    double? y,
    double? size,
  }) {
    return Cloud(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
    );
  }
}

class DinoBoard {
  final Dino dino;
  final List<Obstacle> obstacles;
  final List<Cloud> clouds;
  final int score;
  final int highScore;
  final GameStatus status;
  final double groundY;
  final double worldHeight;
  final double worldWidth;
  final double gameSpeed;

  DinoBoard({
    required this.dino,
    required this.obstacles,
    required this.clouds,
    required this.score,
    required this.highScore,
    required this.status,
    required this.groundY,
    required this.worldHeight,
    required this.worldWidth,
    required this.gameSpeed,
  });

  factory DinoBoard.initial(double worldWidth, double worldHeight) {
    final groundY = worldHeight - 80;
    return DinoBoard(
      dino: Dino(
        y: groundY,
        velocity: 0,
        size: 60,
      ),
      obstacles: [],
      clouds: [],
      score: 0,
      highScore: 0,
      status: GameStatus.ready,
      groundY: groundY,
      worldWidth: worldWidth,
      worldHeight: worldHeight,
      gameSpeed: 4.0,
    );
  }

  DinoBoard copyWith({
    Dino? dino,
    List<Obstacle>? obstacles,
    List<Cloud>? clouds,
    int? score,
    int? highScore,
    GameStatus? status,
    double? groundY,
    double? worldHeight,
    double? worldWidth,
    double? gameSpeed,
  }) {
    return DinoBoard(
      dino: dino ?? this.dino,
      obstacles: obstacles ?? this.obstacles,
      clouds: clouds ?? this.clouds,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      groundY: groundY ?? this.groundY,
      worldHeight: worldHeight ?? this.worldHeight,
      worldWidth: worldWidth ?? this.worldWidth,
      gameSpeed: gameSpeed ?? this.gameSpeed,
    );
  }
}

enum GameStatus {
  ready,
  playing,
  gameOver,
}
