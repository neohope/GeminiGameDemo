import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/tetris/domain/entities/tetris_board.dart';
import 'package:neo_game_suit/features/games/tetris/presentation/providers/tetris_provider.dart';
import 'package:neo_game_suit/features/games/tetris/presentation/widgets/tetris_board_widget.dart';

class TetrisPage extends ConsumerWidget {
  const TetrisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(tetrisProvider);
    final notifier = ref.read(tetrisProvider.notifier);

    return ResponsiveScaffold(
      title: '俄罗斯方块',
      body: Column(
        children: [
          // Main game area with side panels
          Expanded(
            child: Row(
              children: [
                // Left info panel
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '分数',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${board.score}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          const Text(
                            '等级',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${board.level}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Game board (center)
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Expanded(
                        child: TetrisBoardWidget(board: board),
                      ),
                      // Status messages
                      if (board.status == GameStatus.ready)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            '按开始键开始',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (board.status == GameStatus.paused)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            '已暂停',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (board.status == GameStatus.gameOver)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              const Text(
                                '游戏结束！',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              Text('最终分数: ${board.score}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Right info panel (next piece)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '下一个',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          TetrisNextPieceWidget(board: board),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Directional controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlButton(
                      onTap: board.status == GameStatus.playing ? notifier.moveLeft : null,
                      icon: Icons.keyboard_arrow_left,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        _ControlButton(
                          onTap: board.status == GameStatus.playing ? notifier.rotate : null,
                          icon: Icons.rotate_right,
                        ),
                        const SizedBox(height: 2),
                        _ControlButton(
                          onTap: board.status == GameStatus.playing ? notifier.moveDown : null,
                          icon: Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    _ControlButton(
                      onTap: board.status == GameStatus.playing ? notifier.moveRight : null,
                      icon: Icons.keyboard_arrow_right,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => notifier.hardDrop(),
                      icon: const Icon(Icons.south, size: 18),
                      label: const Text('硬降', style: TextStyle(fontSize: 12)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => notifier.startGame(),
                      icon: Icon(board.status == GameStatus.paused ? Icons.play_arrow : Icons.refresh, size: 18),
                      label: Text(board.status == GameStatus.paused ? '继续' : '开始', style: const TextStyle(fontSize: 12)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDifficulty(context, ref, notifier),
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('难度', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDifficulty(BuildContext context, WidgetRef ref, TetrisNotifier notifier) {
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
              final currentDifficulty = ref.read(tetrisProvider).difficulty.difficulty;
              return ListTile(
                title: Text(setting.name),
                trailing: setting.difficulty == currentDifficulty
                    ? const Icon(Icons.check)
                    : null,
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

class _ControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const _ControlButton({
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey : const Color(0xFF333333),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
