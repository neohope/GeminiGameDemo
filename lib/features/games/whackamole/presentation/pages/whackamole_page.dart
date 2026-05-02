import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/whackamole/domain/entities/whackamole_board.dart';
import 'package:neo_game_suit/features/games/whackamole/presentation/providers/whackamole_provider.dart';
import 'package:neo_game_suit/features/games/whackamole/presentation/widgets/whackamole_board_widget.dart';

class WhackAMolePage extends ConsumerWidget {
  const WhackAMolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(whackAMoleProvider);
    final notifier = ref.read(whackAMoleProvider.notifier);

    return ResponsiveScaffold(
      title: '打地鼠',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildInfoBar(context, board),
          Expanded(
            child: WhackAMoleBoardWidget(
              board: board,
              onWhack: (index) {
                notifier.whackMole(index);
              },
            ),
          ),
          if (board.status == GameStatus.ready) _buildReady(context, notifier),
          if (board.status == GameStatus.finished) _buildFinished(context, board, notifier),
          const SizedBox(height: 16),
          _buildControlBar(context, notifier, board),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, WhackAMoleBoard board) {
    final secondsLeft = board.timeLeft.inSeconds;
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InfoBox(
            icon: Icons.score,
            label: '分数',
            value: '${board.score}',
          ),
          const SizedBox(width: 24),
          _InfoBox(
            icon: Icons.timer,
            label: '时间',
            value: '$minutes:$seconds',
          ),
        ],
      ),
    );
  }

  Widget _buildReady(BuildContext context, WhackAMoleNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '准备好了吗？',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => notifier.startGame(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始游戏'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinished(BuildContext context, WhackAMoleBoard board, WhackAMoleNotifier notifier) {
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
            '最终得分: ${board.score}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '命中: ${board.totalWhacks} | 错过: ${board.missedMoles}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WhackAMoleNotifier notifier, WhackAMoleBoard board) {
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

  void _showDifficultySelection(BuildContext context, WhackAMoleNotifier notifier) {
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
                subtitle: Text(
                  '地鼠: ${setting.minMoleDuration.inMilliseconds}-${setting.maxMoleDuration.inMilliseconds}ms, 最多${setting.maxActiveMoles}只',
                ),
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
        color: const Color(0xFF4CAF50),
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
