import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/flappybird/domain/entities/flappybird_board.dart';
import 'package:neo_game_suit/features/games/flappybird/presentation/providers/flappybird_provider.dart';

class FlappyBirdGameWidget extends ConsumerWidget {
  const FlappyBirdGameWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(flappyBirdProvider);
    final notifier = ref.read(flappyBirdProvider.notifier);
    final maxSize = ResponsiveLayout.boardSize(context, maxSize: 350);
    final aspectRatio = board.worldWidth / board.worldHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update world size based on widget size
    });

    return GestureDetector(
      onTap: () => notifier.jump(),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: maxSize,
          height: maxSize / aspectRatio,
          child: _GameCanvas(board: board),
        ),
      ),
    );
  }
}

class _GameCanvas extends StatelessWidget {
  final FlappyBirdBoard board;

  const _GameCanvas({required this.board});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / board.worldWidth;
        final scaleY = constraints.maxHeight / board.worldHeight;

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              // Background sky
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF87CEEB),
                      Color(0xFFB0E0E6),
                    ],
                  ),
                ),
              ),
              // Ground
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80 * scaleY,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFDEB887),
                  ),
                ),
              ),
              // Pipes
              ...board.pipes.map((pipe) {
                return _PipeWidget(
                  pipe: pipe,
                  scaleX: scaleX,
                  scaleY: scaleY,
                );
              }),
              // Bird
              _BirdWidget(
                bird: board.bird,
                scaleX: scaleX,
                scaleY: scaleY,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BirdWidget extends StatelessWidget {
  final Bird bird;
  final double scaleX;
  final double scaleY;

  const _BirdWidget({
    required this.bird,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 80 * scaleX,
      top: bird.y * scaleY,
      child: Transform.rotate(
        angle: (bird.velocity * 0.05).clamp(-0.5, 0.5),
        child: Container(
          width: bird.size * scaleX,
          height: bird.size * scaleY,
          child: Stack(
            children: [
              // Body
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835),
                  borderRadius: BorderRadius.circular(8 * scaleX),
                  border: Border.all(
                    color: const Color(0xFFFBC02D),
                    width: 3 * scaleX,
                  ),
                ),
              ),
              // Wing
              Positioned(
                left: 5 * scaleX,
                top: 15 * scaleY,
                child: Container(
                  width: 15 * scaleX,
                  height: 10 * scaleY,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(4 * scaleX),
                  ),
                ),
              ),
              // Eye
              Positioned(
                right: 8 * scaleX,
                top: 8 * scaleY,
                child: Container(
                  width: 10 * scaleX,
                  height: 10 * scaleY,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 5 * scaleX,
                      height: 5 * scaleY,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              // Beak
              Positioned(
                right: 0,
                top: 18 * scaleY,
                child: Container(
                  width: 12 * scaleX,
                  height: 8 * scaleY,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4 * scaleX),
                      bottomRight: Radius.circular(4 * scaleX),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipeWidget extends StatelessWidget {
  final Pipe pipe;
  final double scaleX;
  final double scaleY;

  const _PipeWidget({
    required this.pipe,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top pipe
        Positioned(
          left: pipe.x * scaleX,
          top: 0,
          width: pipe.width * scaleX,
          height: (pipe.gapY - pipe.gapSize / 2) * scaleY,
          child: const _PipeBody(isTop: true),
        ),
        // Bottom pipe
        Positioned(
          left: pipe.x * scaleX,
          top: (pipe.gapY + pipe.gapSize / 2) * scaleY,
          width: pipe.width * scaleX,
          height: (600 - pipe.gapY - pipe.gapSize / 2) * scaleY,
          child: const _PipeBody(isTop: false),
        ),
      ],
    );
  }
}

class _PipeBody extends StatelessWidget {
  final bool isTop;

  const _PipeBody({required this.isTop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7CB342),
        border: Border.all(
          color: const Color(0xFF558B2F),
          width: 4,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Pipe cap
              Positioned(
                left: -4,
                right: -4,
                top: isTop ? constraints.maxHeight - 24 : 0,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC34A),
                    border: Border.all(
                      color: const Color(0xFF558B2F),
                      width: 4,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
