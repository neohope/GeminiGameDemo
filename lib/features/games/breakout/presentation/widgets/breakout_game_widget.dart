import 'package:flutter/material.dart';
import 'package:neo_game_suit/features/games/breakout/domain/entities/breakout_board.dart';

class BreakoutGameWidget extends StatelessWidget {
  final BreakoutBoard board;
  final Function(double) onPaddleMove;

  const BreakoutGameWidget({
    super.key,
    required this.board,
    required this.onPaddleMove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          onPaddleMove(details.localPosition.dx);
        },
        child: CustomPaint(
          painter: BreakoutPainter(board),
        ),
      ),
    );
  }
}

class BreakoutPainter extends CustomPainter {
  final BreakoutBoard board;

  BreakoutPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgPaint = Paint()..color = const Color(0xFF0F0F23);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw bricks
    for (final brick in board.bricks) {
      _drawBrick(canvas, brick);
    }

    // Draw paddle
    _drawPaddle(canvas, board.paddle);

    // Draw ball
    _drawBall(canvas, board.ball);
  }

  void _drawBrick(Canvas canvas, Brick brick) {
    final paint = Paint()..color = brick.color;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        brick.x,
        brick.y,
        brick.width,
        brick.height,
      ),
      Radius.circular(4),
    );

    // Main brick
    canvas.drawRRect(rect, paint);

    // Highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        brick.x + 2,
        brick.y + 2,
        brick.width - 4,
        brick.height / 2 - 2,
      ),
      Radius.circular(2),
    );
    canvas.drawRRect(highlightRect, highlightPaint);

    // Add border
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rect, borderPaint);

    // Indicate hard bricks
    if (brick.type == BrickType.hard && brick.hits > 1) {
      final indicatorPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(brick.x + brick.width / 2, brick.y + brick.height / 2),
        4,
        indicatorPaint,
      );
    }
  }

  void _drawPaddle(Canvas canvas, Paddle paddle) {
    final paint = Paint()..color = const Color(0xFF4ECDC4);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paddle.x,
        paddle.y,
        paddle.width,
        paddle.height,
      ),
      Radius.circular(6),
    );

    canvas.drawRRect(rect, paint);

    // Paddle border
    final borderPaint = Paint()
      ..color = const Color(0xFF3BA99C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rect, borderPaint);

    // Paddle highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paddle.x + 3,
        paddle.y + 2,
        paddle.width - 6,
        paddle.height / 2 - 2,
      ),
      Radius.circular(4),
    );
    canvas.drawRRect(highlightRect, highlightPaint);
  }

  void _drawBall(Canvas canvas, Ball ball) {
    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFE66D).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius + 4, glowPaint);

    // Main ball
    final ballPaint = Paint()..color = const Color(0xFFFFE66D);
    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, ballPaint);

    // Ball highlight
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(ball.x - ball.radius * 0.3, ball.y - ball.radius * 0.3),
      ball.radius * 0.4,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
