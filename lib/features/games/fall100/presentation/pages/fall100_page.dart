import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/fall100/domain/entities/fall100_board.dart';
import 'package:neo_game_suit/features/games/fall100/presentation/providers/fall100_provider.dart';
import 'package:neo_game_suit/features/games/fall100/presentation/widgets/fall100_game_widget.dart';

class Fall100Page extends ConsumerStatefulWidget {
  const Fall100Page({super.key});

  @override
  ConsumerState<Fall100Page> createState() => _Fall100PageState();
}

class _Fall100PageState extends ConsumerState<Fall100Page> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(fall100Provider);
    final notifier = ref.read(fall100Provider.notifier);

    return ResponsiveScaffold(
      title: '是男人就下100层',
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
            notifier.moveLeft();
            return KeyEventResult.handled;
          }
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.keyD)) {
            notifier.moveRight();
            return KeyEventResult.handled;
          }
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.keyA ||
                  event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.keyD)) {
            notifier.stopMoving();
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
                  return Stack(
                    children: [
                      Fall100GameWidget(board: board),
                      _buildTouchControls(context, notifier, board),
                    ],
                  );
                },
              ),
            ),
            if (board.status == GameStatus.gameOver) _buildGameOver(context, notifier, board),
            if (board.status == GameStatus.ready) _buildReady(context, notifier),
            const SizedBox(height: 16),
            _buildControlBar(context, notifier, board),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchControls(BuildContext context, Fall100Notifier notifier, Fall100Board board) {
    if (board.status == GameStatus.gameOver) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTapDown: (_) {
              if (board.status == GameStatus.ready) {
                notifier.startGame();
              }
              notifier.moveLeft();
            },
            onTapUp: (_) => notifier.stopMoving(),
            onTapCancel: () => notifier.stopMoving(),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTapDown: (_) {
              if (board.status == GameStatus.ready) {
                notifier.startGame();
              }
              notifier.moveRight();
            },
            onTapUp: (_) => notifier.stopMoving(),
            onTapCancel: () => notifier.stopMoving(),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBar(BuildContext context, Fall100Board board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InfoBox(
            title: 'FLOOR',
            value: board.floor,
          ),
          const SizedBox(width: 24),
          _InfoBox(
            title: 'HIGH',
            value: board.highScore,
          ),
        ],
      ),
    );
  }

  Widget _buildReady(BuildContext context, Fall100Notifier notifier) {
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
            '←/A: 左 | →/D: 右',
            style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, Fall100Notifier notifier, Fall100Board board) {
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
            '下到了 ${board.floor} 层！',
            style: const TextStyle(fontSize: 16, color: Color(0xFFFFE66D)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              notifier.reset();
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('再来一次'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, Fall100Notifier notifier, Fall100Board board) {
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
          const SizedBox(width: 16),
          const Text(
            '点击屏幕左/右区域移动',
            style: TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final int value;

  const _InfoBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4ECDC4), width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFFFFE66D),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
