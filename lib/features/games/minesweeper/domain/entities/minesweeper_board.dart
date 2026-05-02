enum CellState {
  covered,
  uncovered,
  flagged,
}

class Cell {
  final int row;
  final int col;
  final bool hasMine;
  CellState state;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.hasMine = false,
    this.state = CellState.covered,
    this.adjacentMines = 0,
  });

  Cell copyWith({
    CellState? state,
    int? adjacentMines,
    bool? hasMine,
  }) {
    return Cell(
      row: row,
      col: col,
      hasMine: hasMine ?? this.hasMine,
      state: state ?? this.state,
      adjacentMines: adjacentMines ?? this.adjacentMines,
    );
  }
}

enum Difficulty {
  easy,
  medium,
  hard,
  custom,
}

class DifficultySettings {
  final Difficulty difficulty;
  final int rows;
  final int cols;
  final int mines;

  const DifficultySettings({
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.mines,
  });

  String get name {
    switch (difficulty) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
      case Difficulty.custom:
        return '自定义';
    }
  }
}

const List<DifficultySettings> defaultDifficulties = [
  DifficultySettings(
    difficulty: Difficulty.easy,
    rows: 9,
    cols: 9,
    mines: 10,
  ),
  DifficultySettings(
    difficulty: Difficulty.medium,
    rows: 16,
    cols: 16,
    mines: 40,
  ),
  DifficultySettings(
    difficulty: Difficulty.hard,
    rows: 16,
    cols: 30,
    mines: 99,
  ),
];

class MinesweeperBoard {
  final List<List<Cell>> cells;
  final int rows;
  final int cols;
  final int mines;
  final int flaggedCount;
  final GameStatus status;
  final DifficultySettings difficulty;
  final bool firstClick;
  final DateTime? startTime;

  MinesweeperBoard({
    required this.cells,
    required this.rows,
    required this.cols,
    required this.mines,
    required this.flaggedCount,
    required this.status,
    required this.difficulty,
    required this.firstClick,
    this.startTime,
  });

  factory MinesweeperBoard.initial(DifficultySettings settings) {
    final cells = List.generate(
      settings.rows,
      (row) => List.generate(
        settings.cols,
        (col) => Cell(row: row, col: col),
      ),
    );
    return MinesweeperBoard(
      cells: cells,
      rows: settings.rows,
      cols: settings.cols,
      mines: settings.mines,
      flaggedCount: 0,
      status: GameStatus.ready,
      difficulty: settings,
      firstClick: true,
    );
  }

  MinesweeperBoard copyWith({
    List<List<Cell>>? cells,
    int? flaggedCount,
    GameStatus? status,
    bool? firstClick,
    DateTime? startTime,
  }) {
    return MinesweeperBoard(
      cells: cells ?? this.cells,
      rows: rows,
      cols: cols,
      mines: mines,
      flaggedCount: flaggedCount ?? this.flaggedCount,
      status: status ?? this.status,
      difficulty: difficulty,
      firstClick: firstClick ?? this.firstClick,
      startTime: startTime ?? this.startTime,
    );
  }

  Cell getCell(int row, int col) {
    return cells[row][col];
  }
}

enum GameStatus {
  ready,
  playing,
  won,
  lost,
}
