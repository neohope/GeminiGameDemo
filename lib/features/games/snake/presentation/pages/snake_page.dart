import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/snake/domain/entities/snake_board.dart';
import 'package:neo_game_suit/features/games/snake/presentation/providers/snake_provider.dart';
import 'package:neo_game_suit/features/games/snake/presentation/widgets/snake_board_widget.dart';

class SnakePage extends ConsumerStatefulWidget {
  const SnakePage({super.key});

  @override
  ConsumerState<SnakePage> createState() => _SnakePageState();
}

class _SnakePageState extends ConsumerState<SnakePage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(snakeProvider);
    final notifier = ref.read(snakeProvider.notifier);

    return ResponsiveScaffold(
      title: 'Snake',
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
            case LogicalKeyboardKey.keyW:
              notifier.changeDirection(Direction.up);
              if (board.isPaused && !board.isGameOver) {
                notifier.start();
              }
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
            case LogicalKeyboardKey.keyS:
              notifier.changeDirection(Direction.down);
              if (board.isPaused && !board.isGameOver) {
                notifier.start();
              }
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
            case LogicalKeyboardKey.keyA:
              notifier.changeDirection(Direction.left);
              if (board.isPaused && !board.isGameOver) {
                notifier.start();
              }
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
            case LogicalKeyboardKey.keyD:
              notifier.changeDirection(Direction.right);
              if (board.isPaused && !board.isGameOver) {
                notifier.start();
              }
              return KeyEventResult.handled;
            case LogicalKeyboardKey.space:
              if (!board.isGameOver) {
                notifier.togglePause();
              }
              return KeyEventResult.handled;
            default:
              return KeyEventResult.ignored;
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildScoreBoard(context, board),
                  ),
                  Expanded(
                    child: Center(
                      child: SnakeBoardWidget(
                        board: board,
                        onDirectionChange: (direction) {
                          notifier.changeDirection(direction);
                          if (board.isPaused && !board.isGameOver) {
                            notifier.start();
                          }
                        },
                        onTap: () {
                          if (!board.isGameOver) {
                            notifier.togglePause();
                          }
                          _focusNode.requestFocus();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 156,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ControlButton(
                                onTap: !board.isGameOver
                                    ? () {
                                        notifier.changeDirection(Direction.up);
                                        if (board.isPaused) {
                                          notifier.start();
                                        }
                                        _focusNode.requestFocus();
                                      }
                                    : null,
                                icon: Icons.keyboard_arrow_up,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _ControlButton(
                              onTap: !board.isGameOver
                                  ? () {
                                      notifier.changeDirection(Direction.left);
                                      if (board.isPaused) {
                                        notifier.start();
                                      }
                                      _focusNode.requestFocus();
                                    }
                                  : null,
                              icon: Icons.keyboard_arrow_left,
                            ),
                            const SizedBox(width: 6),
                            _ControlButton(
                              onTap: !board.isGameOver
                                  ? () {
                                      notifier.changeDirection(Direction.down);
                                      if (board.isPaused) {
                                        notifier.start();
                                      }
                                      _focusNode.requestFocus();
                                    }
                                  : null,
                              icon: Icons.keyboard_arrow_down,
                            ),
                            const SizedBox(width: 6),
                            _ControlButton(
                              onTap: !board.isGameOver
                                  ? () {
                                      notifier.changeDirection(Direction.right);
                                      if (board.isPaused) {
                                        notifier.start();
                                      }
                                      _focusNode.requestFocus();
                                    }
                                  : null,
                              icon: Icons.keyboard_arrow_right,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (board.isGameOver) _buildGameOver(context, notifier),
            if (board.isPaused && !board.isGameOver) _buildPaused(context),
            const SizedBox(height: 16),
            _buildControlBar(context, ref, board, notifier),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context, SnakeBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _ScoreBox(title: 'SCORE', value: board.score),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, SnakeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildPaused(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Paused - Tap to Resume',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, WidgetRef ref, SnakeBoard board, SnakeNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          if (board.isGameOver || board.snake.length == 3)
            ElevatedButton.icon(
              onPressed: () {
                notifier.reset();
                notifier.start();
                _focusNode.requestFocus();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
          if (!board.isGameOver && board.snake.length > 3)
            ElevatedButton.icon(
              onPressed: () {
                notifier.togglePause();
                _focusNode.requestFocus();
              },
              icon: Icon(board.isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(board.isPaused ? 'Resume' : 'Pause'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              notifier.reset();
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String title;
  final int value;

  const _ScoreBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4ECDC4), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
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

class _ControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const _ControlButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 48,
        height: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: onTap == null ? Colors.grey : const Color(0xFF333333),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
