import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants.dart';

class SoftSurfaceCard extends StatelessWidget {
  const SoftSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.border,
    this.shadowColor = AppColors.shadowDark,
    this.highlightOpacity = 0.36,
    this.highlightAlignment = Alignment.topLeft,
    this.highlightRadius = 1.0,
    this.glass = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double highlightOpacity;
  final Alignment highlightAlignment;
  final double highlightRadius;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final decoratedChild = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: glass ? backgroundColor.withValues(alpha: 0.8) : backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: RadialGradient(
                    center: highlightAlignment,
                    radius: highlightRadius,
                    colors: [
                      Colors.white.withValues(alpha: highlightOpacity * 0.78),
                      backgroundColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    if (!glass) {
      return decoratedChild;
    }

    final clipRadius = borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : const BorderRadius.all(Radius.circular(30));

    return ClipRRect(
      borderRadius: clipRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: decoratedChild,
      ),
    );
  }
}
