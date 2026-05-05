import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/dino/domain/entities/dino_board.dart';
import 'package:neo_game_suit/features/games/dino/presentation/providers/dino_provider.dart';
import 'package:neo_game_suit/features/games/dino/presentation/widgets/dino_game_widget.dart';

class DinoPage extends ConsumerStatefulWidget {
  const DinoPage({super.key});

  @override
  ConsumerState<DinoPage> createState() => _DinoPageState();
}

class _DinoPageState extends ConsumerState<DinoPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(dinoProvider);
    final notifier = ref.read(dinoProvider.notifier);

    return ResponsiveScaffold(
      title: 'Chrome Dino',
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.space ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp ||
                  event.logicalKey == LogicalKeyboardKey.keyW)) {
            notifier.jump();
            return KeyEventResult.handled;
          }
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                  event.logicalKey == LogicalKeyboardKey.keyS)) {
            notifier.duck(true);
            return KeyEventResult.handled;
          }
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                  event.logicalKey == LogicalKeyboardKey.keyS)) {
            notifier.duck(false);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildInfoBar(context, board),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  notifier.jump();
                  _focusNode.requestFocus();
                },
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 10) {
                    notifier.duck(true);
                  } else if (details.delta.dy < -10) {
                    notifier.duck(false);
                  }
                },
                onVerticalDragEnd: (_) {
                  notifier.duck(false);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      notifier.setWorldSize(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                    });
                    return DinoGameWidget(board: board);
                  },
                ),
              ),
            ),
            if (board.status == GameStatus.gameOver) _buildGameOver(context, notifier, board),
            const SizedBox(height: 16),
            _buildControlBar(context, notifier, board),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, DinoBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InfoBox(
            title: 'SCORE',
            value: board.score,
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

  Widget _buildGameOver(BuildContext context, DinoNotifier notifier, DinoBoard board) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'GAME OVER',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF535353)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              notifier.reset();
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, DinoNotifier notifier, DinoBoard board) {
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
            label: const Text('New Game'),
          ),
          const SizedBox(width: 16),
          const Text(
            'Space/↑/W: Jump | ↓/S: Duck',
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
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF535353),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
