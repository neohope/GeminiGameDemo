import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/minesweeper/domain/entities/minesweeper_board.dart';

const Color _uncoveredColor = Color(0xFFC0C0C0);
const Color _coveredColor = Color(0xFF808080);
const Color _flaggedColor = Color(0xFFFFD700);
const Color _mineColor = Color(0xFFFF0000);

const List<Color> _numberColors = [
  Colors.transparent,
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.purple,
  Colors.teal,
  Colors.black,
  Colors.grey,
  Colors.orange,
];

class MinesweeperBoardWidget extends StatelessWidget {
  final MinesweeperBoard board;
  final Function(int row, int col) onUncover;
  final Function(int row, int col) onToggleFlag;

  const MinesweeperBoardWidget({
    super.key,
    required this.board,
    required this.onUncover,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    final maxBoardSize = ResponsiveLayout.boardSize(context, maxSize: 550);
    final maxCellWidth = maxBoardSize / board.cols;
    final maxCellHeight = maxBoardSize / board.rows;
    final cellSize = maxCellWidth < maxCellHeight ? maxCellWidth : maxCellHeight;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF808080),
            border: Border.all(color: const Color(0xFF404040), width: 4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: List.generate(board.rows, (row) {
              return Row(
                children: List.generate(board.cols, (col) {
                  return _CellWidget(
                    cell: board.getCell(row, col),
                    cellSize: cellSize,
                    onTap: () => onUncover(row, col),
                    onLongPress: () => onToggleFlag(row, col),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _CellWidget extends StatelessWidget {
  final Cell cell;
  final double cellSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CellWidget({
    required this.cell,
    required this.cellSize,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: cellSize - 2,
        height: cellSize - 2,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: _getCellBorder(),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: _getCellContent(),
        ),
      ),
    );
  }

  Color _getCellColor() {
    if (cell.state == CellState.uncovered) {
      if (cell.hasMine) {
        return _mineColor;
      }
      return _uncoveredColor;
    } else if (cell.state == CellState.flagged) {
      return _flaggedColor;
    }
    return _coveredColor;
  }

  Border? _getCellBorder() {
    if (cell.state == CellState.covered || cell.state == CellState.flagged) {
      return Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2),
        left: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2),
        bottom: BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
        right: BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
      );
    }
    return null;
  }

  Widget? _getCellContent() {
    if (cell.state == CellState.flagged) {
      return Icon(Icons.flag, size: cellSize * 0.6, color: Colors.red);
    } else if (cell.state == CellState.uncovered) {
      if (cell.hasMine) {
        return Icon(Icons.radio_button_checked, size: cellSize * 0.6, color: Colors.black);
      } else if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          style: TextStyle(
            fontSize: cellSize * 0.6,
            fontWeight: FontWeight.bold,
            color: _numberColors[cell.adjacentMines],
          ),
        );
      }
    }
    return null;
  }
}
