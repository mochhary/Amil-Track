import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants.dart';

class AppWatermarkBackground extends StatelessWidget {
  const AppWatermarkBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.backgroundWhite),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _TextureLayer()),
          const Positioned.fill(child: _WatermarkPainterLayer()),
          child,
        ],
      ),
    );
  }
}

class _TextureLayer extends StatelessWidget {
  const _TextureLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _TexturePainter()));
  }
}

class _TexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.02)
      ..strokeWidth = 1;

    for (var y = 0.0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final dotPaint = Paint()
      ..color = AppColors.watermark.withValues(alpha: 0.55);
    for (var y = 18.0; y < size.height; y += 38) {
      for (var x = 18.0; x < size.width; x += 38) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.emerald.withValues(alpha: 0.02),
          Colors.transparent,
          AppColors.gold.withValues(alpha: 0.015),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WatermarkPainterLayer extends StatelessWidget {
  const _WatermarkPainterLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _GeometricWatermarkPainter()),
    );
  }
}

class _GeometricWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.watermark.withValues(alpha: 0.55);

    final center = Offset(size.width * 0.78, size.height * 0.12);
    final radius = size.shortestSide * 0.26;

    for (var i = 0; i < 4; i++) {
      final currentRadius = radius - i * 10;
      final path = Path();
      for (var step = 0; step <= 8; step++) {
        final angle = (step / 8) * math.pi * 2;
        final point = Offset(
          center.dx + currentRadius * math.cos(angle),
          center.dy + currentRadius * math.sin(angle),
        );
        if (step == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    final latticePaint = paint
      ..color = AppColors.watermark.withValues(alpha: 0.35);
    for (var i = 0; i < 5; i++) {
      final offsetX = size.width * 0.1 + i * size.width * 0.14;
      canvas.drawLine(
        Offset(offsetX, size.height * 0.02),
        Offset(offsetX + size.width * 0.06, size.height * 0.16),
        latticePaint,
      );
      canvas.drawLine(
        Offset(offsetX + size.width * 0.06, size.height * 0.02),
        Offset(offsetX, size.height * 0.16),
        latticePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
