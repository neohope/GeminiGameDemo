import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/breakout/domain/entities/breakout_board.dart';
import 'package:neo_game_suit/features/games/breakout/presentation/providers/breakout_provider.dart';
import 'package:neo_game_suit/features/games/breakout/presentation/widgets/breakout_game_widget.dart';

class BreakoutPage extends ConsumerStatefulWidget {
  const BreakoutPage({super.key});

  @override
  ConsumerState<BreakoutPage> createState() => _BreakoutPageState();
}

class _BreakoutPageState extends ConsumerState<BreakoutPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(breakoutProvider);
    final notifier = ref.read(breakoutProvider.notifier);

    return ResponsiveScaffold(
      title: '打砖块',
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (board.status == GameStatus.ready) {
            if (event is KeyDownEvent) {
              notifier.startGame();
              return KeyEventResult.handled;
            }
          }
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.keyA)) {
            notifier.movePaddleLeft();
            return KeyEventResult.handled;
          }
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.keyD)) {
            notifier.movePaddleRight();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildInfoBar(context, board),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    notifier.setWorldSize(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                  });
                  return BreakoutGameWidget(
                    board: board,
                    onPaddleMove: (x) {
                      if (board.status == GameStatus.ready) {
                        notifier.startGame();
                      }
                      notifier.setPaddlePosition(x);
                    },
                  );
                },
              ),
            ),
            if (board.status == GameStatus.gameOver) _buildGameOver(context, notifier, board),
            if (board.status == GameStatus.won) _buildWin(context, notifier, board),
            if (board.status == GameStatus.ready) _buildReady(context, notifier),
            const SizedBox(height: 16),
            _buildControlBar(context, notifier, board),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, BreakoutBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoBox(
            title: 'SCORE',
            value: board.score,
            color: const Color(0xFF4ECDC4),
          ),
          _InfoBox(
            title: 'LEVEL',
            value: board.level,
            color: const Color(0xFFFFE66D),
          ),
          _InfoBox(
            title: 'LIVES',
            value: board.lives,
            color: const Color(0xFFFF6B6B),
          ),
          _InfoBox(
            title: 'HIGH',
            value: board.highScore,
            color: const Color(0xFF96CEB4),
          ),
        ],
      ),
    );
  }

  Widget _buildReady(BuildContext context, BreakoutNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text(
            '按任意键开始',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4ECDC4)),
          ),
          SizedBox(height: 8),
          Text(
            '拖动/←→/AD 移动球拍',
            style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, BreakoutNotifier notifier, BreakoutBoard board) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'GAME OVER',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 8),
          Text(
            '最终得分: ${board.score}',
            style: const TextStyle(fontSize: 16, color: Color(0xFFFFE66D)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              notifier.reset();
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重新开始'),
          ),
        ],
      ),
    );
  }

  Widget _buildWin(BuildContext context, BreakoutNotifier notifier, BreakoutBoard board) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '🎉 恭喜过关！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4ECDC4)),
          ),
          const SizedBox(height: 8),
          Text(
            '第 ${board.level} 关完成！',
            style: const TextStyle(fontSize: 16, color: Color(0xFFFFE66D)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  notifier.nextLevel();
                  _focusNode.requestFocus();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('下一关'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  notifier.reset();
                  _focusNode.requestFocus();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重新开始'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, BreakoutNotifier notifier, BreakoutBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              notifier.reset();
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重新开始'),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
