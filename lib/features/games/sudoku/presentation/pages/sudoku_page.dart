import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/sudoku/presentation/providers/sudoku_provider.dart';
import 'package:neo_game_suit/features/games/sudoku/presentation/widgets/sudoku_board_widget.dart';
import 'package:neo_game_suit/features/games/sudoku/presentation/widgets/sudoku_keypad.dart';

class SudokuPage extends ConsumerWidget {
  const SudokuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sudokuProvider);
    final notifier = ref.read(sudokuProvider.notifier);

    return ResponsiveScaffold(
      title: '数独',
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: SudokuBoardWidget(
                  board: state.board,
                  selectedCell: state.selectedCell,
                  conflictCells: state.conflictCells,
                  isAiSolved: state.isAiSolved,
                  onCellSelected: (index) => notifier.selectCell(index),
                  onCellValueChanged: (value) => notifier.setCellValue(value),
                ),
              ),
              const SizedBox(height: 16),
              SudokuKeypad(
                enabled: !state.isAiSolved && state.selectedCell != null,
                onNumberPressed: (value) => notifier.setCellValue(value),
                onDeletePressed: () => notifier.setCellValue(null),
              ),
              const SizedBox(height: 16),
              _buildControlBar(context, ref, state, notifier),
              const SizedBox(height: 16),
            ],
          ),
          if (state.isPlayerSolved) _buildWinDialog(context, notifier),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WidgetRef ref, SudokuState state, SudokuNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: () => notifier.newGame(),
            icon: const Icon(Icons.refresh),
            label: const Text('新游戏'),
          ),
          ElevatedButton.icon(
            onPressed: state.isAiSolved ? null : () => notifier.reset(),
            icon: const Icon(Icons.restore),
            label: const Text('重置'),
          ),
          ElevatedButton.icon(
            onPressed: state.isAiSolved ? null : () => notifier.solve(),
            icon: const Icon(Icons.lightbulb),
            label: const Text('求解'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.save(),
            icon: const Icon(Icons.save),
            label: const Text('保存'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.folder_open),
            label: const Text('加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildWinDialog(BuildContext context, SudokuNotifier notifier) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '恭喜通关！',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '你太棒了！准备好迎接新的挑战了吗？',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => notifier.newGame(),
                  child: const Text('开始下一关'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
