import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/minesweeper/domain/entities/minesweeper_board.dart';
import 'package:neo_game_suit/features/games/minesweeper/presentation/providers/minesweeper_provider.dart';
import 'package:neo_game_suit/features/games/minesweeper/presentation/widgets/minesweeper_board_widget.dart';

class MinesweeperPage extends ConsumerStatefulWidget {
  const MinesweeperPage({super.key});

  @override
  ConsumerState<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends ConsumerState<MinesweeperPage> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(minesweeperProvider);
    final notifier = ref.read(minesweeperProvider.notifier);

    // Handle timer state
    if (board.status == GameStatus.playing && _timer == null) {
      _startTimer();
    } else if (board.status == GameStatus.won || board.status == GameStatus.lost) {
      _timer?.cancel();
    } else if (board.status == GameStatus.ready && _timer != null) {
      _resetTimer();
    }

    return ResponsiveScaffold(
      title: '扫雷',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildInfoBar(context, board),
          Expanded(
            child: MinesweeperBoardWidget(
              board: board,
              onUncover: (row, col) {
                notifier.uncoverCell(row, col);
              },
              onToggleFlag: (row, col) {
                notifier.toggleFlag(row, col);
              },
            ),
          ),
          if (board.status == GameStatus.won) _buildWin(context, board),
          if (board.status == GameStatus.lost) _buildLost(context, board),
          const SizedBox(height: 16),
          _buildControlBar(context, notifier),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, MinesweeperBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InfoBox(
            icon: Icons.flag,
            value: '${board.mines - board.flaggedCount}',
          ),
          const SizedBox(width: 24),
          _InfoBox(
            icon: Icons.timer,
            value: _formatTime(_elapsedSeconds),
          ),
        ],
      ),
    );
  }

  Widget _buildWin(BuildContext context, MinesweeperBoard board) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '恭喜获胜！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            '用时: ${_formatTime(_elapsedSeconds)}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLost(BuildContext context, MinesweeperBoard board) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        '游戏结束！',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, MinesweeperNotifier notifier) {
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
                onPressed: () {
                  _resetTimer();
                  notifier.reset();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('新游戏'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDifficultySelection(BuildContext context, MinesweeperNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择难度'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: defaultDifficulties.length + 1,
            itemBuilder: (context, index) {
              if (index < defaultDifficulties.length) {
                final setting = defaultDifficulties[index];
                return ListTile(
                  title: Text(setting.name),
                  subtitle: Text('${setting.rows}x${setting.cols} - ${setting.mines}雷'),
                  onTap: () {
                    _resetTimer();
                    notifier.setDifficulty(setting);
                    Navigator.pop(context);
                  },
                );
              } else {
                return ListTile(
                  title: const Text('自定义'),
                  leading: const Icon(Icons.edit),
                  onTap: () {
                    Navigator.pop(context);
                    _showCustomDifficultyDialog(context, notifier);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showCustomDifficultyDialog(BuildContext context, MinesweeperNotifier notifier) {
    int customRows = 9;
    int customCols = 9;
    int customMines = 10;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义难度'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SliderRow(
                  label: '行数',
                  value: customRows,
                  min: 5,
                  max: 20,
                  onChanged: (value) {
                    setDialogState(() {
                      customRows = value;
                      if (customMines >= customRows * customCols) {
                        customMines = customRows * customCols - 1;
                      }
                    });
                  },
                ),
                _SliderRow(
                  label: '列数',
                  value: customCols,
                  min: 5,
                  max: 30,
                  onChanged: (value) {
                    setDialogState(() {
                      customCols = value;
                      if (customMines >= customRows * customCols) {
                        customMines = customRows * customCols - 1;
                      }
                    });
                  },
                ),
                _SliderRow(
                  label: '地雷数',
                  value: customMines,
                  min: 1,
                  max: customRows * customCols - 1,
                  onChanged: (value) {
                    setDialogState(() {
                      customMines = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final customSettings = DifficultySettings(
                difficulty: Difficulty.custom,
                rows: customRows,
                cols: customCols,
                mines: customMines,
              );
              _resetTimer();
              notifier.setDifficulty(customSettings);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoBox({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text('$label:'),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text('$value'),
        ),
      ],
    );
  }
}
