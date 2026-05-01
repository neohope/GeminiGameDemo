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
    return true;
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

  static GoBoard makeMove(GoBoard board, int row, int col) {
    final newBoard = _copyBoard(board.board);
    newBoard[row][col] = board.currentPlayer;

    final opponent = board.currentPlayer == blackPlayer ? whitePlayer : blackPlayer;
    var captures = 0;

    for (final dir in [(0, 1), (1, 0), (0, -1), (-1, 0)]) {
      final nr = row + dir.$1;
      final nc = col + dir.$2;
      if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize) {
        final group = findGroup(GoBoard(board: newBoard, currentPlayer: opponent, blackCaptures: 0, whiteCaptures: 0, lastPass: false), nr, nc, opponent);
        if (group != null && group.liberties.isEmpty) {
          captures += group.stones.length;
          for (final (sr, sc) in group.stones) {
            newBoard[sr][sc] = null;
          }
        }
      }
    }

    final ownGroup = findGroup(GoBoard(board: newBoard, currentPlayer: board.currentPlayer, blackCaptures: 0, whiteCaptures: 0, lastPass: false), row, col, board.currentPlayer);
    if (ownGroup != null && ownGroup.liberties.isEmpty) {
      return board;
    }

    final nextPlayer = opponent;
    final newBlackCaptures = board.currentPlayer == blackPlayer ? board.blackCaptures + captures : board.blackCaptures;
    final newWhiteCaptures = board.currentPlayer == whitePlayer ? board.whiteCaptures + captures : board.whiteCaptures;

    return GoBoard(
      board: newBoard,
      currentPlayer: nextPlayer,
      blackCaptures: newBlackCaptures,
      whiteCaptures: newWhiteCaptures,
      lastPass: false,
    );
  }

  static GoBoard pass(GoBoard board) {
    final nextPlayer = board.currentPlayer == blackPlayer ? whitePlayer : blackPlayer;
    return board.copyWith(currentPlayer: nextPlayer, lastPass: true);
  }

  static List<List<Player?>> _copyBoard(List<List<Player?>> board) {
    return board.map((row) => List<Player?>.from(row)).toList();
  }
}
