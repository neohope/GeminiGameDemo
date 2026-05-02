import 'dart:math';
import 'package:neo_game_suit/features/games/minesweeper/domain/entities/minesweeper_board.dart';

class MinesweeperLogic {
  static MinesweeperBoard placeMines(MinesweeperBoard board, int safeRow, int safeCol) {
    final random = Random();
    final newCells = _deepCopyCells(board.cells);
    var minesPlaced = 0;

    while (minesPlaced < board.mines) {
      final row = random.nextInt(board.rows);
      final col = random.nextInt(board.cols);

      // Don't place mine on or adjacent to first click
      final isSafe = (row == safeRow && col == safeCol) ||
          (row >= safeRow - 1 && row <= safeRow + 1 && col >= safeCol - 1 && col <= safeCol + 1);
      if (isSafe || newCells[row][col].hasMine) {
        continue;
      }

      newCells[row][col] = newCells[row][col].copyWith(hasMine: true);
      minesPlaced++;
    }

    // Calculate adjacent mine counts
    _calculateAdjacentMines(newCells, board.rows, board.cols);

    return board.copyWith(
      cells: newCells,
      firstClick: false,
      status: GameStatus.playing,
      startTime: DateTime.now(),
    );
  }

  static void _calculateAdjacentMines(List<List<Cell>> cells, int rows, int cols) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (cells[row][col].hasMine) continue;
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = row + dr;
            final nc = col + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && cells[nr][nc].hasMine) {
              count++;
            }
          }
        }
        cells[row][col] = cells[row][col].copyWith(adjacentMines: count);
      }
    }
  }

  static MinesweeperBoard uncoverCell(MinesweeperBoard board, int row, int col) {
    if (board.status == GameStatus.won || board.status == GameStatus.lost) {
      return board;
    }

    final cell = board.getCell(row, col);
    if (cell.state != CellState.covered) {
      return board;
    }

    final newCells = _deepCopyCells(board.cells);

    // If first click, place mines first
    if (board.firstClick) {
      var placedBoard = placeMines(board, row, col);
      return uncoverCell(placedBoard, row, col);
    }

    // Game over if mine uncovered
    if (newCells[row][col].hasMine) {
      newCells[row][col] = newCells[row][col].copyWith(state: CellState.uncovered);
      _revealAllMines(newCells, board.rows, board.cols);
      return board.copyWith(cells: newCells, status: GameStatus.lost);
    }

    // Flood fill
    _floodUncover(newCells, row, col, board.rows, board.cols);

    // Check win condition
    if (_checkWin(newCells, board.rows, board.cols, board.mines)) {
      _flagAllMines(newCells, board.rows, board.cols);
      return board.copyWith(cells: newCells, status: GameStatus.won, flaggedCount: board.mines);
    }

    return board.copyWith(cells: newCells);
  }

  static MinesweeperBoard toggleFlag(MinesweeperBoard board, int row, int col) {
    if (board.status == GameStatus.won || board.status == GameStatus.lost) {
      return board;
    }

    final cell = board.getCell(row, col);
    if (cell.state == CellState.uncovered) {
      return board;
    }

    final newCells = _deepCopyCells(board.cells);
    final newState = cell.state == CellState.covered ? CellState.flagged : CellState.covered;
    newCells[row][col] = newCells[row][col].copyWith(state: newState);

    final newFlaggedCount = newState == CellState.flagged ? board.flaggedCount + 1 : board.flaggedCount - 1;

    return board.copyWith(cells: newCells, flaggedCount: newFlaggedCount);
  }

  static void _floodUncover(List<List<Cell>> cells, int row, int col, int rows, int cols) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return;
    if (cells[row][col].state != CellState.covered) return;

    cells[row][col] = cells[row][col].copyWith(state: CellState.uncovered);

    if (cells[row][col].adjacentMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _floodUncover(cells, row + dr, col + dc, rows, cols);
        }
      }
    }
  }

  static void _revealAllMines(List<List<Cell>> cells, int rows, int cols) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (cells[row][col].hasMine) {
          cells[row][col] = cells[row][col].copyWith(state: CellState.uncovered);
        }
      }
    }
  }

  static void _flagAllMines(List<List<Cell>> cells, int rows, int cols) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (cells[row][col].hasMine && cells[row][col].state != CellState.flagged) {
          cells[row][col] = cells[row][col].copyWith(state: CellState.flagged);
        }
      }
    }
  }

  static bool _checkWin(List<List<Cell>> cells, int rows, int cols, int mines) {
    int coveredCount = 0;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (cells[row][col].state == CellState.covered || cells[row][col].state == CellState.flagged) {
          coveredCount++;
        }
      }
    }
    return coveredCount == mines;
  }

  static List<List<Cell>> _deepCopyCells(List<List<Cell>> cells) {
    return cells.map((row) => row.map((c) => c.copyWith()).toList()).toList();
  }

  static MinesweeperBoard reset(DifficultySettings settings) {
    return MinesweeperBoard.initial(settings);
  }
}
