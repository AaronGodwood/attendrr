import 'dart:math';
import 'package:flutter/material.dart';

/// Subtle noise/grain texture overlay for warmth.
/// Applied on Check-In and Profile pages only, at 3-5% opacity.
class GrainOverlay extends StatelessWidget {
  final double opacity;

  const GrainOverlay({super.key, this.opacity = 0.04});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: const CustomPaint(
            painter: _GrainPainter(),
            isComplex: true,
            willChange: false,
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent pattern
    final paint = Paint()..style = PaintingStyle.fill;

    // Warm-tinted dots
    const warmColor = Color(0xFFC67B4E);
    final dotCount = (size.width * size.height / 80).toInt().clamp(0, 5000);

    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = 0.3 + random.nextDouble() * 0.7;
      paint.color = warmColor.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), 0.5 + random.nextDouble() * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
