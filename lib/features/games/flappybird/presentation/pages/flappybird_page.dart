import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/flappybird/domain/entities/flappybird_board.dart';
import 'package:neo_game_suit/features/games/flappybird/presentation/providers/flappybird_provider.dart';
import 'package:neo_game_suit/features/games/flappybird/presentation/widgets/flappybird_game_widget.dart';

class FlappyBirdPage extends ConsumerWidget {
  const FlappyBirdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(flappyBirdProvider);
    final notifier = ref.read(flappyBirdProvider.notifier);

    return ResponsiveScaffold(
      title: 'Flappy Bird',
      body: Column(
        children: [
          _buildInfoBar(context, board),
          Expanded(
            child: const FlappyBirdGameWidget(),
          ),
          if (board.status == GameStatus.ready) _buildReady(context, notifier),
          if (board.status == GameStatus.gameOver) _buildGameOver(context, board, notifier),
          const SizedBox(height: 16),
          _buildControlBar(context, notifier, board),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, FlappyBirdBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _InfoBox(
            icon: Icons.score,
            label: '分数',
            value: '${board.score}',
          ),
          const SizedBox(width: 24),
          _InfoBox(
            icon: Icons.star,
            label: '最高分',
            value: '${board.highScore}',
          ),
        ],
      ),
    );
  }

  Widget _buildReady(BuildContext context, FlappyBirdNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        '点击屏幕开始！',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, FlappyBirdBoard board, FlappyBirdNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '游戏结束！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '得分: ${board.score}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, FlappyBirdNotifier notifier, FlappyBirdBoard board) {
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
                onPressed: () => _showDifficultySelection(context, notifier),
                icon: const Icon(Icons.settings),
                label: const Text('难度'),
              ),
              ElevatedButton.icon(
                onPressed: () => notifier.reset(),
                icon: const Icon(Icons.refresh),
                label: const Text('新游戏'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDifficultySelection(BuildContext context, FlappyBirdNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择难度'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: defaultDifficulties.length,
            itemBuilder: (context, index) {
              final setting = defaultDifficulties[index];
              return ListTile(
                title: Text(setting.name),
                onTap: () {
                  notifier.setDifficulty(setting);
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

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
