class SnakeBoard {
  static const int defaultWidth = 20;
  static const int defaultHeight = 20;

  final int width;
  final int height;
  final List<Point> snake;
  final Point food;
  final Direction direction;
  final Direction? nextDirection;
  final int score;
  final bool isGameOver;
  final bool isPaused;
  final int speed;

  SnakeBoard({
    this.width = defaultWidth,
    this.height = defaultHeight,
    required this.snake,
    required this.food,
    required this.direction,
    this.nextDirection,
    this.score = 0,
    this.isGameOver = false,
    this.isPaused = false,
    this.speed = 350,
  });

  factory SnakeBoard.initial() {
    final initialSnake = [
      Point(10, 10),
      Point(9, 10),
      Point(8, 10),
    ];
    return SnakeBoard(
      snake: initialSnake,
      food: _generateFood(initialSnake, defaultWidth, defaultHeight),
      direction: Direction.right,
      isPaused: true,
    );
  }

  SnakeBoard copyWith({
    int? width,
    int? height,
    List<Point>? snake,
    Point? food,
    Direction? direction,
    Direction? nextDirection,
    int? score,
    bool? isGameOver,
    bool? isPaused,
    int? speed,
  }) {
    return SnakeBoard(
      width: width ?? this.width,
      height: height ?? this.height,
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      nextDirection: nextDirection,
      score: score ?? this.score,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      speed: speed ?? this.speed,
    );
  }

  static Point _generateFood(List<Point> snake, int width, int height) {
    while (true) {
      final x = DateTime.now().millisecond % width;
      final y = DateTime.now().second % height;
      final point = Point(x, y);
      if (!snake.contains(point)) {
        return point;
      }
    }
  }
}

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Point move(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Point(x, y - 1);
      case Direction.down:
        return Point(x, y + 1);
      case Direction.left:
        return Point(x - 1, y);
      case Direction.right:
        return Point(x + 1, y);
    }
  }
}

enum Direction {
  up,
  down,
  left,
  right,
}
