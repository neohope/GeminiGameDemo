import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/gomoku/domain/entities/gomoku_board.dart';
import 'package:neo_game_suit/features/games/gomoku/presentation/providers/gomoku_provider.dart';
import 'package:neo_game_suit/features/games/gomoku/presentation/widgets/gomoku_board_widget.dart';

class GomokuPage extends ConsumerWidget {
  const GomokuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gomokuProvider);
    final notifier = ref.read(gomokuProvider.notifier);

    return ResponsiveScaffold(
      title: '五子棋',
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              _buildStatus(context, state),
              Expanded(
                child: GomokuBoardWidget(
                  board: state.board,
                  enabled: !state.isAiThinking && state.winner == null,
                  onMove: (row, col) => notifier.makeMove(row, col),
                ),
              ),
              const SizedBox(height: 16),
              _buildControlBar(context, ref, state, notifier),
              const SizedBox(height: 16),
            ],
          ),
          if (state.isAiThinking) _buildThinkingIndicator(context),
          if (state.winner != null) _buildWinDialog(context, state.winner!, notifier),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, GomokuState state) {
    final bgColor = state.board.currentPlayer == blackPlayer ? Colors.white : Colors.black87;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('当前: '),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: state.board.currentPlayer == whitePlayer ? Border.all(color: Colors.black26) : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              state.board.currentPlayer == blackPlayer ? '黑方' : '白方',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WidgetRef ref, GomokuState state, GomokuNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          DropdownButton<GameMode>(
            value: state.gameMode,
            items: const [
              DropdownMenuItem(
                value: GameMode.hvh,
                child: Text('人人对战'),
              ),
              DropdownMenuItem(
                value: GameMode.hva,
                child: Text('人机对战'),
              ),
            ],
            onChanged: state.history.length <= 1 ? (value) => value != null ? notifier.setGameMode(value) : null : null,
          ),
          ElevatedButton.icon(
            onPressed: state.history.length <= 1 || state.winner != null ? null : () => notifier.undo(),
            icon: const Icon(Icons.undo),
            label: const Text('悔棋'),
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
          ElevatedButton.icon(
            onPressed: () => notifier.reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI 思考中...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinDialog(BuildContext context, Player winner, GomokuNotifier notifier) {
    final winnerName = winner == blackPlayer ? '黑方' : '白方';
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
                  '$winnerName 获胜！',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: winner == blackPlayer ? Colors.black : Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => notifier.reset(),
                  child: const Text('再来一局'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
