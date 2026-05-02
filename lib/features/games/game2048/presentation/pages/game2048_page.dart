import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/game2048/domain/usecases/game2048_logic.dart';
import 'package:neo_game_suit/features/games/game2048/presentation/providers/game2048_provider.dart';
import 'package:neo_game_suit/features/games/game2048/presentation/widgets/game2048_board_widget.dart';

class Game2048Page extends ConsumerWidget {
  const Game2048Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(game2048Provider);
    final notifier = ref.read(game2048Provider.notifier);

    return ResponsiveScaffold(
      title: '2048',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildScoreBoard(context, state, notifier),
          Expanded(
            child: Game2048BoardWidget(
              board: state.board,
              onMove: (direction) => notifier.move(direction),
            ),
          ),
          if (state.board.gameOver || state.board.isWin)
            _buildGameOver(context, state, notifier),
          const SizedBox(height: 16),
          _buildControlBar(context, ref, state, notifier),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScoreBoard(
    BuildContext context,
    Game2048State state,
    Game2048Notifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScoreBox(title: 'SCORE', value: state.board.score),
          const SizedBox(width: 16),
          _ScoreBox(title: 'BEST', value: state.board.bestScore),
        ],
      ),
    );
  }

  Widget _buildGameOver(
    BuildContext context,
    Game2048State state,
    Game2048Notifier notifier,
  ) {
    final isWin = state.board.isWin && !state.board.gameOver;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            isWin ? 'You Win!' : 'Game Over!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            isWin ? 'You reached 2048! Keep going!' : 'Try again!',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(
    BuildContext context,
    WidgetRef ref,
    Game2048State state,
    Game2048Notifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: state.history.length <= 1 ? null : () => notifier.undo(),
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.save(),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.folder_open),
            label: const Text('Load'),
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String title;
  final int value;

  const _ScoreBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFCDC1B4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFEEE4DA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
