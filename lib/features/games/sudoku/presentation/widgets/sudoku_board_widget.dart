import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/sudoku/domain/entities/sudoku_board.dart';

class SudokuBoardWidget extends StatelessWidget {
  final SudokuBoard board;
  final int? selectedCell;
  final Set<int> conflictCells;
  final bool isAiSolved;
  final ValueChanged<int> onCellSelected;
  final ValueChanged<int?> onCellValueChanged;

  const SudokuBoardWidget({
    super.key,
    required this.board,
    required this.selectedCell,
    required this.conflictCells,
    required this.isAiSolved,
    required this.onCellSelected,
    required this.onCellValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 700);
    final cellSize = boardSize / 9;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                _buildGridLines(cellSize),
                _buildCells(context, cellSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridLines(double cellSize) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _SudokuGridPainter(cellSize: cellSize),
      ),
    );
  }

  Widget _buildCells(BuildContext context, double cellSize) {
    return SizedBox.expand(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          return _buildCell(context, index, cellSize);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, int index, double cellSize) {
    final row = index ~/ 9;
    final col = index % 9;
    final value = board.board[index];
    final isInitial = board.isInitialCell(index);
    final isSelected = selectedCell == index;
    final hasConflict = conflictCells.contains(index);

    bool shouldHighlight = false;
    if (selectedCell != null && !isAiSolved) {
      final selectedRow = selectedCell! ~/ 9;
      final selectedCol = selectedCell! % 9;
      if (row == selectedRow || col == selectedCol) {
        shouldHighlight = true;
      } else {
        final boxRow = (row / 3).floor();
        final boxCol = (col / 3).floor();
        final selectedBoxRow = (selectedRow / 3).floor();
        final selectedBoxCol = (selectedCol / 3).floor();
        if (boxRow == selectedBoxRow && boxCol == selectedBoxCol) {
          shouldHighlight = true;
        }
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor = Colors.transparent;
    if (isSelected && !isAiSolved) {
      bgColor = colorScheme.secondaryContainer;
    } else if (shouldHighlight) {
      bgColor = isInitial ? colorScheme.outlineVariant.withValues(alpha: 0.3) : colorScheme.primaryContainer.withValues(alpha: 0.3);
    }

    TextStyle textStyle = TextStyle(
      fontSize: cellSize * 0.5,
      fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
      color: isInitial ? colorScheme.onSurface : colorScheme.primary,
    );
    if (hasConflict && !isAiSolved) {
      textStyle = textStyle.copyWith(color: colorScheme.error);
    } else if (isAiSolved && !isInitial) {
      textStyle = textStyle.copyWith(color: colorScheme.outline);
    }

    return InkWell(
      onTap: () => onCellSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.transparent, width: 0),
        ),
        child: isInitial
            ? Center(
                child: Text(
                  value?.toString() ?? '',
                  style: textStyle,
                ),
              )
            : TextField(
                textAlign: TextAlign.center,
                style: textStyle,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                controller: TextEditingController(text: value?.toString() ?? '')
                  ..selection = TextSelection.collapsed(offset: value?.toString().length ?? 0),
                inputFormatters: const [],
                keyboardType: TextInputType.number,
                enabled: !isAiSolved,
                onTap: () => onCellSelected(index),
                onChanged: (value) {
                  if (value.isEmpty) {
                    onCellValueChanged(null);
                  } else if (value.length == 1 && int.tryParse(value) != null) {
                    onCellValueChanged(int.parse(value));
                  }
                },
              ),
      ),
    );
  }
}

class _SudokuGridPainter extends CustomPainter {
  final double cellSize;

  _SudokuGridPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final thickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3;

    for (int i = 1; i < 9; i++) {
      final paint = i % 3 == 0 ? thickPaint : thinPaint;
      final offset = i * cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }

    final borderPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(_SudokuGridPainter oldDelegate) => oldDelegate.cellSize != cellSize;
}
