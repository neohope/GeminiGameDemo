import 'package:flutter/material.dart';
import 'package:neo_game_suit/features/games/fall100/domain/entities/fall100_board.dart';

class Fall100GameWidget extends StatelessWidget {
  final Fall100Board board;

  const Fall100GameWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: CustomPaint(
        painter: Fall100Painter(board),
      ),
    );
  }
}

class Fall100Painter extends CustomPainter {
  final Fall100Board board;

  Fall100Painter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF16213E), const Color(0xFF1A1A2E)],
    );
    final bgPaint = Paint()..shader = gradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Save canvas and apply camera transform
    canvas.save();
    canvas.translate(0, board.cameraY);

    // Draw platforms
    for (final platform in board.platforms) {
      _drawPlatform(canvas, platform);
    }

    // Draw player
    _drawPlayer(canvas, board.player);

    canvas.restore();
  }

  void _drawPlatform(Canvas canvas, Platform platform) {
    Paint paint;

    switch (platform.type) {
      case PlatformType.normal:
        paint = Paint()..color = const Color(0xFF4ECDC4);
        break;
      case PlatformType.breakable:
        paint = Paint()..color = const Color(0xFFFFE66D);
        break;
      case PlatformType.spike:
        _drawSpike(canvas, platform);
        return;
      case PlatformType.moving:
        paint = Paint()..color = const Color(0xFFE94560);
        break;
    }

    // Draw platform
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        platform.x,
        platform.y,
        platform.width,
        platform.height,
      ),
      Radius.circular(4),
    );
    canvas.drawRRect(rRect, paint);

    // Platform border
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rRect, borderPaint);
  }

  void _drawSpike(Canvas canvas, Platform platform) {
    final spikePaint = Paint()..color = const Color(0xFFFF6B6B);
    const spikeCount = 8;
    final spikeWidth = platform.width / spikeCount;

    for (int i = 0; i < spikeCount; i++) {
      final path = Path();
      path.moveTo(platform.x + i * spikeWidth, platform.y + platform.height);
      path.lineTo(platform.x + i * spikeWidth + spikeWidth / 2, platform.y);
      path.lineTo(platform.x + (i + 1) * spikeWidth, platform.y + platform.height);
      path.close();
      canvas.drawPath(path, spikePaint);
    }
  }

  void _drawPlayer(Canvas canvas, Player player) {
    final paint = Paint()..color = const Color(0xFFFFE66D);

    // Body
    final bodyRect = Rect.fromLTWH(
      player.x + 5,
      player.y + 10,
      player.size - 10,
      player.size - 15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(8)),
      paint,
    );

    // Head
    final headRect = Rect.fromLTWH(
      player.x + 8,
      player.y,
      player.size - 16,
      player.size * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(8)),
      paint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1A1A2E);
    final eyeOffset = player.facingRight ? 5 : -5;
    canvas.drawCircle(
      Offset(player.x + player.size / 2 + eyeOffset, player.y + player.size * 0.2),
      4,
      eyePaint,
    );

    // Player border
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(8)),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(8)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
