import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/game2048/domain/entities/game2048_board.dart';
import 'package:neo_game_suit/features/games/game2048/domain/usecases/game2048_logic.dart';

const int _boardSize = 4;

const Map<int, Color> _tileColors = {
  0: Color(0xFFCDC1B4),
  2: Color(0xFFEEE4DA),
  4: Color(0xFFEDE0C8),
  8: Color(0xFFF2B179),
  16: Color(0xFFF59563),
  32: Color(0xFFF67C5F),
  64: Color(0xFFF65E3B),
  128: Color(0xFFEDCF72),
  256: Color(0xFFEDCC61),
  512: Color(0xFFEDC850),
  1024: Color(0xFFEDC53F),
  2048: Color(0xFFEDC22E),
  4096: Color(0xFF3C3A32),
  8192: Color(0xFF3C3A32),
};

const Map<int, Color> _textColor = {
  2: Color(0xFF776E65),
  4: Color(0xFF776E65),
  8: Color(0xFFF9F6F2),
  16: Color(0xFFF9F6F2),
  32: Color(0xFFF9F6F2),
  64: Color(0xFFF9F6F2),
  128: Color(0xFFF9F6F2),
  256: Color(0xFFF9F6F2),
  512: Color(0xFFF9F6F2),
  1024: Color(0xFFF9F6F2),
  2048: Color(0xFFF9F6F2),
  4096: Color(0xFFF9F6F2),
  8192: Color(0xFFF9F6F2),
};

class Game2048BoardWidget extends StatelessWidget {
  final Game2048Board board;
  final Function(MoveDirection) onMove;

  const Game2048BoardWidget({
    super.key,
    required this.board,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 650);
    final tileSize = (boardSize - 40) / _boardSize;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              onMove(MoveDirection.up);
            } else if (details.primaryVelocity! > 0) {
              onMove(MoveDirection.down);
            }
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              onMove(MoveDirection.left);
            } else if (details.primaryVelocity! > 0) {
              onMove(MoveDirection.right);
            }
          },
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: const Color(0xFFBBADA0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  _buildBackgroundGrid(tileSize),
                  _buildTiles(tileSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGrid(double tileSize) {
    final children = <Widget>[];
    for (int i = 0; i < _boardSize; i++) {
      for (int j = 0; j < _boardSize; j++) {
        children.add(
          Positioned(
            left: j * (tileSize + 8),
            top: i * (tileSize + 8),
            child: Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                color: _tileColors[0],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }
    }
    return Stack(children: children);
  }

  Widget _buildTiles(double tileSize) {
    final children = <Widget>[];
    for (int i = 0; i < _boardSize; i++) {
      for (int j = 0; j < _boardSize; j++) {
        final value = board.getTile(i, j);
        if (value > 0) {
          children.add(
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: j * (tileSize + 8),
              top: i * (tileSize + 8),
              child: Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: _tileColors[value] ?? _tileColors[8192],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: tileSize * 0.4,
                      fontWeight: FontWeight.bold,
                      color: _textColor[value] ?? _textColor[8192],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    return Stack(children: children);
  }
}
