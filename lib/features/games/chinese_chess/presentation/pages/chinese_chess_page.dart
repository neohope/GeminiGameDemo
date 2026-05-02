import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/chinese_chess/domain/entities/chinese_chess_board.dart';
import 'package:neo_game_suit/features/games/chinese_chess/presentation/providers/chinese_chess_provider.dart';
import 'package:neo_game_suit/features/games/chinese_chess/presentation/widgets/chinese_chess_board_widget.dart';

class ChineseChessPage extends ConsumerWidget {
  const ChineseChessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chineseChessProvider);
    final notifier = ref.read(chineseChessProvider.notifier);

    return ResponsiveScaffold(
      title: '中国象棋',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildStatus(context, state),
          Expanded(
            child: ChineseChessBoardWidget(
              board: state.board,
              selectedPiece: state.selectedPiece,
              onCellTap: (x, y) => notifier.selectCell(x, y),
              enabled: !state.isAiThinking && state.winner == null,
            ),
          ),
          const SizedBox(height: 16),
          _buildControlBar(context, ref, state, notifier),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, ChineseChessState state) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.winner != null) ...[
              Text(
                state.winner == redPlayer ? '红方' : '黑方',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
              ),
              const Text(' 获胜!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ] else if (state.isAiThinking) ...[
              const Text('AI 思考中...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
            ] else ...[
              const Text('当前: '),
              Text(
                state.board.currentPlayer == redPlayer ? '红方' : '黑方',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (state.gameMode == GameMode.hva)
                Text(
                  state.board.currentPlayer == redPlayer ? ' (玩家)' : ' (AI)',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WidgetRef ref, ChineseChessState state, ChineseChessNotifier notifier) {
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
            onPressed: state.history.length <= 1 ? null : () => notifier.undo(),
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
}
