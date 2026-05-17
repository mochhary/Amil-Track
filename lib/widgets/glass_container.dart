import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.blur = 15.0,
    this.glassOpacity = 0.15,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double glassOpacity;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Bayangan lembut agar kartu terlihat melayang (Elevated)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          // Mesin utama efek kaca buram (Frosted Glass)
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Gradasi warna semi-transparan khas desain iOS Premium
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor?.withValues(alpha: glassOpacity + 0.15) ?? 
                      Colors.white.withValues(alpha: glassOpacity + 0.15),
                  backgroundColor?.withValues(alpha: glassOpacity) ?? 
                      Colors.white.withValues(alpha: glassOpacity),
                ],
              ),
              // Garis tepi tipis untuk mempertegas pantulan cahaya
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}