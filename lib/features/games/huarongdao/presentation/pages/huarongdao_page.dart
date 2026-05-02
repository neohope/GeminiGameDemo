import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/huarongdao/domain/entities/huarongdao_board.dart';
import 'package:neo_game_suit/features/games/huarongdao/presentation/providers/huarongdao_provider.dart';
import 'package:neo_game_suit/features/games/huarongdao/presentation/widgets/huarongdao_board_widget.dart';

class HuarongdaoPage extends ConsumerWidget {
  const HuarongdaoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(huarongdaoProvider);
    final notifier = ref.read(huarongdaoProvider.notifier);
    final currentLevel = levels.firstWhere((l) => l.id == board.levelId);

    return ResponsiveScaffold(
      title: '华容道',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildInfo(context, board, currentLevel),
          Expanded(
            child: HuarongdaoBoardWidget(
              board: board,
              onMovePiece: (piece, dRow, dCol) {
                notifier.movePiece(piece, dRow, dCol);
              },
            ),
          ),
          if (board.isWon) _buildWin(context, notifier, board),
          const SizedBox(height: 16),
          _buildControlBar(context, notifier),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, HuarongdaoBoard board, HuarongdaoLevel level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            level.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 24),
          Text(
            '步数: ${board.moveCount}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildWin(BuildContext context, HuarongdaoNotifier notifier, HuarongdaoBoard board) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '恭喜通关！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '总步数: ${board.moveCount}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, HuarongdaoNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showLevelSelection(context, notifier),
                icon: const Icon(Icons.menu),
                label: const Text('选择关卡'),
              ),
              ElevatedButton.icon(
                onPressed: () => notifier.reset(),
                icon: const Icon(Icons.refresh),
                label: const Text('重新开始'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLevelSelection(BuildContext context, HuarongdaoNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择关卡'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return ListTile(
                title: Text(level.name),
                onTap: () {
                  notifier.selectLevel(level);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
