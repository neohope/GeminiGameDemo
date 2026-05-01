import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/go/domain/entities/go_board.dart';
import 'package:neo_game_suit/features/games/go/presentation/providers/go_provider.dart';
import 'package:neo_game_suit/features/games/go/presentation/widgets/go_board_widget.dart';

class GoPage extends ConsumerWidget {
  const GoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goProvider);
    final notifier = ref.read(goProvider.notifier);

    return ResponsiveScaffold(
      title: '围棋',
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              _buildStatus(context, state),
              Expanded(
                child: GoBoardWidget(
                  board: state.board,
                  enabled: !state.gameOver,
                  onMove: (row, col) => notifier.makeMove(row, col),
                ),
              ),
              const SizedBox(height: 16),
              _buildControlBar(context, ref, state, notifier),
              const SizedBox(height: 16),
            ],
          ),
          if (state.gameOver) _buildGameOverOverlay(context),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, GoState state) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('黑提子: ${state.board.whiteCaptures}'),
            Text('当前: ${state.board.currentPlayer == blackPlayer ? '黑方' : '白方'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('白提子: ${state.board.blackCaptures}'),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WidgetRef ref, GoState state, GoNotifier notifier) {
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
            onPressed: state.gameOver ? null : () => notifier.pass(),
            icon: const Icon(Icons.pan_tool),
            label: const Text('停着'),
          ),
          ElevatedButton.icon(
            onPressed: state.history.length <= 1 || state.gameOver ? null : () => notifier.undo(),
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

  Widget _buildGameOverOverlay(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              '游戏结束',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
