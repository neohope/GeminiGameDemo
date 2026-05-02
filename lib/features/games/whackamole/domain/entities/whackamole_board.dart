enum HoleState {
  empty,
  mole,
  whacked,
}

class Hole {
  final int index;
  HoleState state;
  DateTime? appearTime;
  Duration? duration;

  Hole({
    required this.index,
    this.state = HoleState.empty,
    this.appearTime,
    this.duration,
  });

  Hole copyWith({
    HoleState? state,
    DateTime? appearTime,
    Duration? duration,
  }) {
    return Hole(
      index: index,
      state: state ?? this.state,
      appearTime: appearTime ?? this.appearTime,
      duration: duration ?? this.duration,
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
  final Duration gameDuration;
  final Duration minMoleDuration;
  final Duration maxMoleDuration;
  final int maxActiveMoles;

  const DifficultySettings({
    required this.difficulty,
    required this.gameDuration,
    required this.minMoleDuration,
    required this.maxMoleDuration,
    required this.maxActiveMoles,
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
    gameDuration: Duration(seconds: 60),
    minMoleDuration: Duration(milliseconds: 1500),
    maxMoleDuration: Duration(milliseconds: 2500),
    maxActiveMoles: 2,
  ),
  DifficultySettings(
    difficulty: Difficulty.medium,
    gameDuration: Duration(seconds: 60),
    minMoleDuration: Duration(milliseconds: 1000),
    maxMoleDuration: Duration(milliseconds: 2000),
    maxActiveMoles: 3,
  ),
  DifficultySettings(
    difficulty: Difficulty.hard,
    gameDuration: Duration(seconds: 60),
    minMoleDuration: Duration(milliseconds: 600),
    maxMoleDuration: Duration(milliseconds: 1200),
    maxActiveMoles: 4,
  ),
];

class WhackAMoleBoard {
  final List<Hole> holes;
  final int rows;
  final int cols;
  final int score;
  final int totalWhacks;
  final int missedMoles;
  final GameStatus status;
  final DifficultySettings difficulty;
  final DateTime? startTime;
  final Duration timeLeft;

  WhackAMoleBoard({
    required this.holes,
    required this.rows,
    required this.cols,
    required this.score,
    required this.totalWhacks,
    required this.missedMoles,
    required this.status,
    required this.difficulty,
    required this.timeLeft,
    this.startTime,
  });

  factory WhackAMoleBoard.initial(DifficultySettings settings) {
    const rows = 3;
    const cols = 3;
    final holes = List.generate(
      rows * cols,
      (index) => Hole(index: index),
    );
    return WhackAMoleBoard(
      holes: holes,
      rows: rows,
      cols: cols,
      score: 0,
      totalWhacks: 0,
      missedMoles: 0,
      status: GameStatus.ready,
      difficulty: settings,
      timeLeft: settings.gameDuration,
    );
  }

  WhackAMoleBoard copyWith({
    List<Hole>? holes,
    int? score,
    int? totalWhacks,
    int? missedMoles,
    GameStatus? status,
    DateTime? startTime,
    Duration? timeLeft,
  }) {
    return WhackAMoleBoard(
      holes: holes ?? this.holes,
      rows: rows,
      cols: cols,
      score: score ?? this.score,
      totalWhacks: totalWhacks ?? this.totalWhacks,
      missedMoles: missedMoles ?? this.missedMoles,
      status: status ?? this.status,
      difficulty: difficulty,
      startTime: startTime ?? this.startTime,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }

  Hole getHole(int index) {
    return holes[index];
  }
}

enum GameStatus {
  ready,
  playing,
  finished,
}
