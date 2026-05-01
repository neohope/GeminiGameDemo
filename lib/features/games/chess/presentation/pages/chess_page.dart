import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/chess/domain/entities/chess_board.dart';
import 'package:neo_game_suit/features/games/chess/presentation/providers/chess_provider.dart';
import 'package:neo_game_suit/features/games/chess/presentation/widgets/chess_board_widget.dart';

class ChessPage extends ConsumerWidget {
  const ChessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessProvider);
    final notifier = ref.read(chessProvider.notifier);

    return ResponsiveScaffold(
      title: '国际象棋',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildStatus(context, state),
          Expanded(
            child: ChessBoardWidget(
              board: state.board,
              selectedPiece: state.selectedPiece,
              onCellTap: (row, col) => notifier.selectCell(row, col),
            ),
          ),
          const SizedBox(height: 16),
          _buildControlBar(context, ref, state, notifier),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, ChessState state) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('当前: '),
            Text(
              state.board.currentPlayer == whitePlayer ? '白方' : '黑方',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WidgetRef ref, ChessState state, ChessNotifier notifier) {
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
