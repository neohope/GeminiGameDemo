import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/minesweeper/domain/entities/minesweeper_board.dart';

const Color _uncoveredColor = Color(0xFFFAEBD7);
const Color _coveredColor = Color(0xFFDEB887);
const Color _flaggedColor = Color(0xFFFF8C00);
const Color _mineColor = Color(0xFFFF4500);

const List<Color> _numberColors = [
  Colors.transparent,
  Color(0xFF00BFFF),
  Color(0xFF32CD32),
  Color(0xFFFF6347),
  Color(0xFFBA55D3),
  Color(0xFF00CED1),
  Color(0xFF8B008B),
  Color(0xFFFF69B4),
  Color(0xFFFFD700),
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
    final maxBoardSize = ResponsiveLayout.boardSize(context, maxSize: 750);
    final maxCellWidth = maxBoardSize / board.cols;
    final maxCellHeight = maxBoardSize / board.rows;
    final cellSize = maxCellWidth < maxCellHeight ? maxCellWidth : maxCellHeight;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE6E6FA), Color(0xFFB0C4DE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF4169E1), width: 5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4169E1).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: List.generate(board.rows, (row) {
              return Row(
                children: List.generate(board.cols, (col) {
                  return _CellWidget(
                    cell: board.getCell(row, col),
                    cellSize: cellSize,
                    onTap: () => onUncover(row, col),
                    onToggleFlag: () => onToggleFlag(row, col),
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
  final VoidCallback onToggleFlag;

  const _CellWidget({
    required this.cell,
    required this.cellSize,
    required this.onTap,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onToggleFlag,
      onSecondaryTap: onToggleFlag,
      child: Container(
        width: cellSize - 2,
        height: cellSize - 2,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: _getCellBorder(),
          borderRadius: BorderRadius.circular(6),
          boxShadow: _getBoxShadow(),
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

  List<BoxShadow>? _getBoxShadow() {
    if (cell.state == CellState.flagged) {
      return [
        BoxShadow(
          color: _flaggedColor.withValues(alpha: 0.6),
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ];
    } else if (cell.state == CellState.uncovered && cell.hasMine) {
      return [
        BoxShadow(
          color: _mineColor.withValues(alpha: 0.6),
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ];
    }
    return null;
  }

  Border? _getCellBorder() {
    if (cell.state == CellState.covered || cell.state == CellState.flagged) {
      return Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
        left: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
        bottom: BorderSide(color: Colors.black.withValues(alpha: 0.25), width: 2.5),
        right: BorderSide(color: Colors.black.withValues(alpha: 0.25), width: 2.5),
      );
    }
    return null;
  }

  Widget? _getCellContent() {
    if (cell.state == CellState.flagged) {
      return Icon(Icons.flag, size: cellSize * 0.6, color: Colors.red[700]);
    } else if (cell.state == CellState.uncovered) {
      if (cell.hasMine) {
        return Icon(Icons.radio_button_checked, size: cellSize * 0.6, color: Colors.black87);
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
