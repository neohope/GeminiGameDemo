const int boardSize = 3;

enum Player {
  x,
  o,
  none,
}

enum GameMode {
  hvh, // Human vs Human
  hva, // Human vs AI
}

enum GameStatus {
  playing,
  xWon,
  oWon,
  draw,
}

class TicTacToeBoard {
  final List<List<Player>> board;
  final Player currentPlayer;
  final GameStatus status;
  final GameMode mode;
  final Player humanPlayer;
  final List<List<int>>? winningLine;

  TicTacToeBoard({
    required this.board,
    required this.currentPlayer,
    required this.status,
    required this.mode,
    this.humanPlayer = Player.x,
    this.winningLine,
  });

  factory TicTacToeBoard.initial({GameMode mode = GameMode.hvh}) {
    final emptyBoard = List.generate(
      boardSize,
      (_) => List.filled(boardSize, Player.none),
    );
    return TicTacToeBoard(
      board: emptyBoard,
      currentPlayer: Player.x,
      status: GameStatus.playing,
      mode: mode,
    );
  }

  TicTacToeBoard copyWith({
    List<List<Player>>? board,
    Player? currentPlayer,
    GameStatus? status,
    GameMode? mode,
    Player? humanPlayer,
    List<List<int>>? winningLine,
  }) {
    return TicTacToeBoard(
      board: board ?? _deepCopyBoard(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      humanPlayer: humanPlayer ?? this.humanPlayer,
      winningLine: winningLine ?? this.winningLine,
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
