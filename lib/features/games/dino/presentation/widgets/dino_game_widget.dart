import 'package:flutter/material.dart';
import 'package:neo_game_suit/features/games/dino/domain/entities/dino_board.dart';

class DinoGameWidget extends StatelessWidget {
  final DinoBoard board;

  const DinoGameWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7F7),
      child: CustomPaint(
        painter: DinoPainter(board),
      ),
    );
  }
}

class DinoPainter extends CustomPainter {
  final DinoBoard board;

  DinoPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    final dinoColor = Paint()..color = const Color(0xFF535353);
    final obstacleColor = Paint()..color = const Color(0xFF535353);
    final cloudColor = Paint()..color = const Color(0xFFC4C4C4);
    final groundColor = Paint()..color = const Color(0xFF535353);

    // Draw ground
    canvas.drawRect(
      Rect.fromLTWH(0, board.groundY, size.width, 2),
      groundColor,
    );

    // Draw clouds
    for (final cloud in board.clouds) {
      _drawCloud(canvas, cloud, cloudColor);
    }

    // Draw obstacles
    for (final obstacle in board.obstacles) {
      _drawObstacle(canvas, obstacle, obstacleColor);
    }

    // Draw dino
    _drawDino(canvas, board.dino, dinoColor);
  }

  void _drawDino(Canvas canvas, Dino dino, Paint paint) {
    final x = 100.0;
    final y = dino.y;
    final size = dino.size;

    if (dino.isDucking) {
      // Ducking dino - draw lower and shorter
      final duckHeight = size * 0.6;
      final duckY = y + size - duckHeight;

      canvas.drawRect(
        Rect.fromLTWH(x, duckY, size * 1.4, duckHeight),
        paint,
      );
      // Head
      canvas.drawRect(
        Rect.fromLTWH(x + size * 0.8, duckY, size * 0.6, duckHeight * 0.6),
        paint,
      );
    } else {
      // Standing dino
      canvas.drawRect(
        Rect.fromLTWH(x, y, size * 0.7, size),
        paint,
      );
      // Head
      canvas.drawRect(
        Rect.fromLTWH(x + size * 0.4, y - size * 0.4, size * 0.7, size * 0.5),
        paint,
      );
      // Eye (white)
      final eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(x + size * 0.85, y - size * 0.15), size * 0.08, eyePaint);
    }
  }

  void _drawObstacle(Canvas canvas, Obstacle obstacle, Paint paint) {
    switch (obstacle.type) {
      case ObstacleType.smallCactus:
        _drawCactus(canvas, obstacle, paint, small: true);
        break;
      case ObstacleType.largeCactus:
        _drawCactus(canvas, obstacle, paint, small: false);
        break;
      case ObstacleType.bird:
        _drawBird(canvas, obstacle, paint);
        break;
    }
  }

  void _drawCactus(Canvas canvas, Obstacle obstacle, Paint paint, {required bool small}) {
    final height = small ? 40.0 : 70.0;
    final baseWidth = small ? 20.0 : 30.0;
    final armWidth = small ? 10.0 : 15.0;
    final armHeight = small ? 20.0 : 35.0;

    // Main body
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x + (obstacle.width - baseWidth) / 2,
        obstacle.y,
        baseWidth,
        height,
      ),
      paint,
    );

    // Left arm
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x + (obstacle.width - baseWidth) / 2 - armWidth,
        obstacle.y + height * 0.3,
        armWidth,
        armHeight,
      ),
      paint,
    );

    // Right arm
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x + (obstacle.width - baseWidth) / 2 + baseWidth,
        obstacle.y + height * 0.5,
        armWidth,
        armHeight * 0.8,
      ),
      paint,
    );
  }

  void _drawBird(Canvas canvas, Obstacle obstacle, Paint paint) {
    final centerY = obstacle.y + obstacle.height / 2;

    // Body
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x,
        centerY - 10,
        obstacle.width,
        20,
      ),
      paint,
    );

    // Head
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x + obstacle.width - 15,
        centerY - 8,
        15,
        16,
      ),
      paint,
    );

    // Beak
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x + obstacle.width,
        centerY - 3,
        12,
        6,
      ),
      paint,
    );

    // Wings
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x + 10,
        centerY - 18,
        20,
        8,
      ),
      paint,
    );
  }

  void _drawCloud(Canvas canvas, Cloud cloud, Paint paint) {
    final x = cloud.x;
    final y = cloud.y;
    final size = cloud.size;

    // Draw cloud with multiple circles
    canvas.drawCircle(Offset(x, y), size * 0.5, paint);
    canvas.drawCircle(Offset(x + size * 0.4, y - size * 0.15), size * 0.4, paint);
    canvas.drawCircle(Offset(x + size * 0.8, y), size * 0.45, paint);
    canvas.drawCircle(Offset(x + size * 0.4, y + size * 0.2), size * 0.35, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
