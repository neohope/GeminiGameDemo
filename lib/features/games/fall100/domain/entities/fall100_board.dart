class Player {
  final double x;
  final double y;
  final double velocityY;
  final double velocityX;
  final double size;
  final bool facingRight;

  Player({
    required this.x,
    required this.y,
    required this.velocityY,
    required this.velocityX,
    required this.size,
    this.facingRight = true,
  });

  Player copyWith({
    double? x,
    double? y,
    double? velocityY,
    double? velocityX,
    double? size,
    bool? facingRight,
  }) {
    return Player(
      x: x ?? this.x,
      y: y ?? this.y,
      velocityY: velocityY ?? this.velocityY,
      velocityX: velocityX ?? this.velocityX,
      size: size ?? this.size,
      facingRight: facingRight ?? this.facingRight,
    );
  }
}

class Platform {
  final double x;
  final double y;
  final double width;
  final double height;
  final PlatformType type;

  Platform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });

  Platform copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    PlatformType? type,
  }) {
    return Platform(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
    );
  }
}

enum PlatformType {
  normal,
  breakable,
  spike,
  moving,
}

class Fall100Board {
  final Player player;
  final List<Platform> platforms;
  final int score;
  final int highScore;
  final int floor;
  final GameStatus status;
  final double worldHeight;
  final double worldWidth;
  final double cameraY;

  Fall100Board({
    required this.player,
    required this.platforms,
    required this.score,
    required this.highScore,
    required this.floor,
    required this.status,
    required this.worldHeight,
    required this.worldWidth,
    required this.cameraY,
  });

  static Platform _generatePlatform(double worldWidth, double y, int floor) {
    final random = (y.toInt() * 13 + floor * 7) % 100;
    final x = (random / 100.0) * (worldWidth - 100) + 20;

    PlatformType type;
    final typeRandom = (random + floor * 3) % 100;
    if (typeRandom < 60) {
      type = PlatformType.normal;
    } else if (typeRandom < 80) {
      type = PlatformType.breakable;
    } else if (typeRandom < 95) {
      type = PlatformType.spike;
    } else {
      type = PlatformType.moving;
    }

    return Platform(
      x: x,
      y: y,
      width: 70 + (random % 40).toDouble(),
      height: 15,
      type: type,
    );
  }

  factory Fall100Board.initial(double worldWidth, double worldHeight) {
    final platforms = <Platform>[];

    // Starting platform
    platforms.add(Platform(
      x: worldWidth / 2 - 60,
      y: worldHeight - 100,
      width: 120,
      height: 20,
      type: PlatformType.normal,
    ));

    // Generate initial platforms
    for (int i = 1; i <= 15; i++) {
      platforms.add(_generatePlatform(worldWidth, worldHeight - 100 - i * 100, i));
    }

    return Fall100Board(
      player: Player(
        x: worldWidth / 2 - 20,
        y: worldHeight - 150,
        velocityY: 0,
        velocityX: 0,
        size: 40,
      ),
      platforms: platforms,
      score: 0,
      highScore: 0,
      floor: 0,
      status: GameStatus.ready,
      worldHeight: worldHeight,
      worldWidth: worldWidth,
      cameraY: 0,
    );
  }

  Fall100Board copyWith({
    Player? player,
    List<Platform>? platforms,
    int? score,
    int? highScore,
    int? floor,
    GameStatus? status,
    double? worldHeight,
    double? worldWidth,
    double? cameraY,
  }) {
    return Fall100Board(
      player: player ?? this.player,
      platforms: platforms ?? this.platforms,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      worldHeight: worldHeight ?? this.worldHeight,
      worldWidth: worldWidth ?? this.worldWidth,
      cameraY: cameraY ?? this.cameraY,
    );
  }
}

enum GameStatus {
  ready,
  playing,
  gameOver,
}
