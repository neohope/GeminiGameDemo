import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/whackamole/domain/entities/whackamole_board.dart';

class WhackAMoleBoardWidget extends StatelessWidget {
  final WhackAMoleBoard board;
  final Function(int index) onWhack;

  const WhackAMoleBoardWidget({
    super.key,
    required this.board,
    required this.onWhack,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 450);
    final holeSize = boardSize / board.cols;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: boardSize,
          height: boardSize * board.rows / board.cols,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            border: Border.all(color: const Color(0xFF2E7D32), width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.cols,
            ),
            itemCount: board.rows * board.cols,
            itemBuilder: (context, index) {
              return _HoleWidget(
                hole: board.getHole(index),
                holeSize: holeSize,
                onWhack: () => onWhack(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HoleWidget extends StatelessWidget {
  final Hole hole;
  final double holeSize;
  final VoidCallback onWhack;

  const _HoleWidget({
    required this.hole,
    required this.holeSize,
    required this.onWhack,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onWhack,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hole (dark circle)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // Mole
            if (hole.state == HoleState.mole)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
                transform: Matrix4.identity(),
                child: _MoleWidget(size: holeSize * 0.7),
              ),
            // Whacked state (stars)
            if (hole.state == HoleState.whacked)
              Icon(
                Icons.star,
                size: holeSize * 0.5,
                color: Colors.yellow,
              ),
          ],
        ),
      ),
    );
  }
}

class _MoleWidget extends StatelessWidget {
  final double size;

  const _MoleWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63),
              shape: BoxShape.circle,
            ),
          ),
          // Eyes
          Positioned(
            top: size * 0.2,
            left: size * 0.25,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.2,
            right: size * 0.25,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Nose
          Positioned(
            bottom: size * 0.25,
            child: SizedBox(
              width: size * 0.2,
              height: size * 0.12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(size * 0.06),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
