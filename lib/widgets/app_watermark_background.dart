import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppWatermarkBackground extends StatelessWidget {
  const AppWatermarkBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // PERUBAHAN: Warna dipertegas (Dari putih krem ke hijau sage lembut)
          colors: [Color(0xFFFCFBF8), Color(0xFFDCE7DF)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _GridLayer()),
          const Positioned.fill(child: _AmbientLayer()),
          const Positioned.fill(child: _ShimmerLayer()),
          child,
        ],
      ),
    );
  }
}

class _GridLayer extends StatelessWidget {
  const _GridLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.emeraldDeep.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final dotPaint = Paint()
      ..color = AppColors.emeraldDeep.withValues(alpha: 0.18); 
    for (var y = 16.0; y < size.height; y += 38) {
      for (var x = 16.0; x < size.width; x += 38) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.emerald.withValues(alpha: 0.08),
          Colors.transparent,
          AppColors.gold.withValues(alpha: 0.07),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AmbientLayer extends StatelessWidget {
  const _AmbientLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _AmbientPainter()));
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()..style = PaintingStyle.fill;

    // PERUBAHAN: Opacity ambient dinaikkan agar gradasi cahaya lebih kentara
    circlePaint.color = AppColors.emerald.withValues(alpha: 0.12);
    circlePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.08),
      size.shortestSide * 0.18,
      circlePaint,
    );

    circlePaint.color = AppColors.gold.withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.12),
      size.shortestSide * 0.14,
      circlePaint,
    );

    circlePaint.color = AppColors.orangeGold.withValues(alpha: 0.10);
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.88),
      size.shortestSide * 0.16,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShimmerLayer extends StatelessWidget {
  const _ShimmerLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.emerald.withValues(alpha: 0.04),
              Colors.transparent,
              AppColors.gold.withValues(alpha: 0.035),
            ],
          ),
        ),
      ),
    );
  }
}