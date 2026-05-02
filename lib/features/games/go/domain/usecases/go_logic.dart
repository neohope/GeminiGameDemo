import 'package:neo_game_suit/features/games/go/domain/entities/go_board.dart';

class Group {
  final List<(int, int)> stones;
  final List<(int, int)> liberties;

  Group(this.stones, this.liberties);
}

class GoLogic {
  static bool isValidMove(GoBoard board, int row, int col) {
    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) return false;
    if (board.getPiece(row, col) != null) return false;
    if (board.koPoint != null && board.koPoint!.$1 == row && board.koPoint!.$2 == col) return false;

    final tempBoard = _tryMove(board, row, col);
    return tempBoard != null;
  }

  static Group? findGroup(GoBoard board, int row, int col, Player player) {
    if (board.getPiece(row, col) != player) return null;

    final visited = <(int, int)>{};
    final stones = <(int, int)>[];
    final liberties = <(int, int)>{};
    final queue = <(int, int)>[(row, col)];

    while (queue.isNotEmpty) {
      final (r, c) = queue.removeAt(0);
      if (visited.contains((r, c))) continue;
      visited.add((r, c));

      final piece = board.getPiece(r, c);
      if (piece == player) {
        stones.add((r, c));
        for (final dir in [(0, 1), (1, 0), (0, -1), (-1, 0)]) {
          final nr = r + dir.$1;
          final nc = c + dir.$2;
          if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize) {
            queue.add((nr, nc));
          }
        }
      } else if (piece == null) {
        liberties.add((r, c));
      }
    }

    return Group(stones, liberties.toList());
  }

  static GoBoard? _tryMove(GoBoard board, int row, int col) {
    final newBoard = _copyBoard(board.board);
    newBoard[row][col] = board.currentPlayer;

    final opponent = board.currentPlayer == blackPlayer ? whitePlayer : blackPlayer;
    var captures = 0;
    var capturedSingleStone = false;
    (int, int)? capturedPoint;

    for (final dir in [(0, 1), (1, 0), (0, -1), (-1, 0)]) {
      final nr = row + dir.$1;
      final nc = col + dir.$2;
      if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize) {
        final group = findGroup(GoBoard(board: newBoard, currentPlayer: opponent, blackCaptures: 0, whiteCaptures: 0, lastPass: false), nr, nc, opponent);
        if (group != null && group.liberties.isEmpty) {
          captures += group.stones.length;
          if (group.stones.length == 1) {
            capturedSingleStone = true;
            capturedPoint = group.stones.first;
          }
          for (final (sr, sc) in group.stones) {
            newBoard[sr][sc] = null;
          }
        }
      }
    }

    final ownGroup = findGroup(GoBoard(board: newBoard, currentPlayer: board.currentPlayer, blackCaptures: 0, whiteCaptures: 0, lastPass: false), row, col, board.currentPlayer);
    if (ownGroup != null && ownGroup.liberties.isEmpty) {
      return null;
    }

    (int, int)? newKoPoint;
    if (capturedSingleStone && capturedPoint != null) {
      final tempGroup = findGroup(
        GoBoard(board: newBoard, currentPlayer: board.currentPlayer, blackCaptures: 0, whiteCaptures: 0, lastPass: false),
        row, col, board.currentPlayer
      );
      if (tempGroup != null && tempGroup.liberties.length == 1 && tempGroup.stones.length == 1) {
        newKoPoint = capturedPoint;
      }
    }

    return GoBoard(
      board: newBoard,
      currentPlayer: opponent,
      blackCaptures: board.currentPlayer == blackPlayer ? board.blackCaptures + captures : board.blackCaptures,
      whiteCaptures: board.currentPlayer == whitePlayer ? board.whiteCaptures + captures : board.whiteCaptures,
      lastPass: false,
      koPoint: newKoPoint,
    );
  }

  static GoBoard? makeMove(GoBoard board, int row, int col) {
    if (!isValidMove(board, row, col)) return null;
    return _tryMove(board, row, col);
  }

  static GoBoard pass(GoBoard board) {
    final nextPlayer = board.currentPlayer == blackPlayer ? whitePlayer : blackPlayer;
    return board.copyWith(currentPlayer: nextPlayer, lastPass: true, koPoint: null);
  }

  static List<List<Player?>> _copyBoard(List<List<Player?>> board) {
    return board.map((row) => List<Player?>.from(row)).toList();
  }
}
