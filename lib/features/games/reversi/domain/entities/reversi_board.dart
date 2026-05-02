const int boardSize = 8;

enum Player {
  black,
  white,
  none,
}

enum GameMode {
  hvh, // Human vs Human
  hva, // Human vs AI
}

enum GameStatus {
  playing,
  blackWon,
  whiteWon,
  draw,
}

class ReversiBoard {
  final List<List<Player>> board;
  final Player currentPlayer;
  final GameStatus status;
  final GameMode mode;
  final Player humanPlayer;
  final int blackScore;
  final int whiteScore;
  final List<List<int>>? lastFlipped;
  final (int, int)? lastMove;

  ReversiBoard({
    required this.board,
    required this.currentPlayer,
    required this.status,
    required this.mode,
    this.humanPlayer = Player.black,
    this.blackScore = 2,
    this.whiteScore = 2,
    this.lastFlipped,
    this.lastMove,
  });

  factory ReversiBoard.initial({GameMode mode = GameMode.hvh}) {
    final emptyBoard = List.generate(
      boardSize,
      (_) => List.filled(boardSize, Player.none),
    );
    // Initial position
    emptyBoard[3][3] = Player.white;
    emptyBoard[3][4] = Player.black;
    emptyBoard[4][3] = Player.black;
    emptyBoard[4][4] = Player.white;

    return ReversiBoard(
      board: emptyBoard,
      currentPlayer: Player.black,
      status: GameStatus.playing,
      mode: mode,
    );
  }

  ReversiBoard copyWith({
    List<List<Player>>? board,
    Player? currentPlayer,
    GameStatus? status,
    GameMode? mode,
    Player? humanPlayer,
    int? blackScore,
    int? whiteScore,
    List<List<int>>? lastFlipped,
    (int, int)? lastMove,
  }) {
    return ReversiBoard(
      board: board ?? _deepCopyBoard(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      humanPlayer: humanPlayer ?? this.humanPlayer,
      blackScore: blackScore ?? this.blackScore,
      whiteScore: whiteScore ?? this.whiteScore,
      lastFlipped: lastFlipped ?? this.lastFlipped,
      lastMove: lastMove ?? this.lastMove,
    );
  }

  static List<List<Player>> _deepCopyBoard(List<List<Player>> board) {
    return board.map((row) => List<Player>.from(row)).toList();
  }

  Player getTile(int row, int col) {
    return board[row][col];
  }

  bool isTileEmpty(int row, int col) {
    return board[row][col] == Player.none;
  }
}
