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
    // Request focus after build
    Future.microtask(() {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(snakeProvider);

    return ResponsiveScaffold(
      title: 'Snake',
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (board) => KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is! KeyDownEvent) return;

            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
              case LogicalKeyboardKey.keyW:
                ref.read(snakeProvider.notifier).changeDirection(Direction.up);
                if (!board.isPaused && !board.isGameOver && board.snake.length == 3) {
                  ref.read(snakeProvider.notifier).start();
                }
              case LogicalKeyboardKey.arrowDown:
              case LogicalKeyboardKey.keyS:
                ref.read(snakeProvider.notifier).changeDirection(Direction.down);
                if (!board.isPaused && !board.isGameOver && board.snake.length == 3) {
                  ref.read(snakeProvider.notifier).start();
                }
              case LogicalKeyboardKey.arrowLeft:
              case LogicalKeyboardKey.keyA:
                ref.read(snakeProvider.notifier).changeDirection(Direction.left);
                if (!board.isPaused && !board.isGameOver && board.snake.length == 3) {
                  ref.read(snakeProvider.notifier).start();
                }
              case LogicalKeyboardKey.arrowRight:
              case LogicalKeyboardKey.keyD:
                ref.read(snakeProvider.notifier).changeDirection(Direction.right);
                if (!board.isPaused && !board.isGameOver && board.snake.length == 3) {
                  ref.read(snakeProvider.notifier).start();
                }
              case LogicalKeyboardKey.space:
                if (!board.isGameOver) {
                  ref.read(snakeProvider.notifier).togglePause();
                }
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
                            ref.read(snakeProvider.notifier).changeDirection(direction);
                            if (!board.isPaused && !board.isGameOver && board.snake.length == 3) {
                              ref.read(snakeProvider.notifier).start();
                            }
                          },
                          onTap: () {
                            if (!board.isGameOver) {
                              ref.read(snakeProvider.notifier).togglePause();
                            }
                            // Request focus when tapping the game area
                            _focusNode.requestFocus();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (board.isGameOver) _buildGameOver(context, ref),
              if (board.isPaused && !board.isGameOver) _buildPaused(context),
              const SizedBox(height: 16),
              // Directional controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlButton(
                      onTap: !board.isGameOver
                          ? () {
                              ref.read(snakeProvider.notifier).changeDirection(Direction.left);
                              if (!board.isPaused && board.snake.length == 3) {
                                ref.read(snakeProvider.notifier).start();
                              }
                              _focusNode.requestFocus();
                            }
                          : null,
                      icon: Icons.keyboard_arrow_left,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        _ControlButton(
                          onTap: !board.isGameOver
                              ? () {
                                  ref.read(snakeProvider.notifier).changeDirection(Direction.up);
                                  if (!board.isPaused && board.snake.length == 3) {
                                    ref.read(snakeProvider.notifier).start();
                                  }
                                  _focusNode.requestFocus();
                                }
                              : null,
                          icon: Icons.keyboard_arrow_up,
                        ),
                        const SizedBox(height: 2),
                        _ControlButton(
                          onTap: !board.isGameOver
                              ? () {
                                  ref.read(snakeProvider.notifier).changeDirection(Direction.down);
                                  if (!board.isPaused && board.snake.length == 3) {
                                    ref.read(snakeProvider.notifier).start();
                                  }
                                  _focusNode.requestFocus();
                                }
                              : null,
                          icon: Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    _ControlButton(
                      onTap: !board.isGameOver
                          ? () {
                              ref.read(snakeProvider.notifier).changeDirection(Direction.right);
                              if (!board.isPaused && board.snake.length == 3) {
                                ref.read(snakeProvider.notifier).start();
                              }
                              _focusNode.requestFocus();
                            }
                          : null,
                      icon: Icons.keyboard_arrow_right,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildControlBar(context, ref, board),
              const SizedBox(height: 16),
            ],
          ),
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

  Widget _buildGameOver(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Game Over!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(snakeProvider.notifier).reset(),
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

  Widget _buildControlBar(BuildContext context, WidgetRef ref, SnakeBoard board) {
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
                ref.read(snakeProvider.notifier).reset();
                ref.read(snakeProvider.notifier).start();
                _focusNode.requestFocus();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
          if (!board.isGameOver && board.snake.length > 3)
            ElevatedButton.icon(
              onPressed: () {
                ref.read(snakeProvider.notifier).togglePause();
                _focusNode.requestFocus();
              },
              icon: Icon(board.isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(board.isPaused ? 'Resume' : 'Pause'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(snakeProvider.notifier).reset();
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE94560),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
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
