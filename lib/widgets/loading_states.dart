import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'amil_track_logo.dart';
import 'soft_surface_card.dart';

class GlassLoadingSplash extends StatefulWidget {
  const GlassLoadingSplash({super.key, this.title = 'Amil Track'});

  final String title;

  @override
  State<GlassLoadingSplash> createState() => _GlassLoadingSplashState();
}

class _GlassLoadingSplashState extends State<GlassLoadingSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 1 + (_controller.value * 0.03);
        final fade = 0.8 + (_controller.value * 0.2);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: pulse,
                  child: _GlassBadge(
                    child: const AmilTrackLogo(size: 156, showTitle: false),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Opacity(
                  opacity: fade,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.emeraldDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _LoadingSkeletonCard(widthFactor: 0.88),
                const SizedBox(height: AppSpacing.md),
                const _LoadingSkeletonCard(widthFactor: 0.74),
                const SizedBox(height: AppSpacing.md),
                const _LoadingSkeletonCard(widthFactor: 0.58),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonDashboard extends StatefulWidget {
  const SkeletonDashboard({super.key});

  @override
  State<SkeletonDashboard> createState() => _SkeletonDashboardState();
}

class _SkeletonDashboardState extends State<SkeletonDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmer = 0.35 + (_controller.value * 0.35);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            110,
          ),
          children: [
            _ShimmerCard(
              height: 130,
              alpha: shimmer,
              child: const _SkeletonBlock(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ShimmerCard(
              height: 320,
              alpha: shimmer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SkeletonLine(widthFactor: 0.55, height: 18),
                  SizedBox(height: 14),
                  _SkeletonLine(widthFactor: 0.88, height: 12),
                  SizedBox(height: 8),
                  _SkeletonLine(widthFactor: 0.72, height: 12),
                  SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _SkeletonTile()),
                      SizedBox(width: AppSpacing.md),
                      Expanded(child: _SkeletonTile()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: const [
                Expanded(child: _SkeletonTile(height: 86)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: _SkeletonTile(height: 86)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(38),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 142,
          height: 142,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({
    required this.height,
    required this.alpha,
    required this.child,
  });

  final double height;
  final double alpha;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(28),
      padding: EdgeInsets.zero,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.softSurface.withValues(alpha: alpha),
              Colors.white,
            ],
            stops: const [0, 0.5, 1],
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile({this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _SkeletonLine(widthFactor: 0.62, height: 14),
            SizedBox(height: 10),
            _SkeletonLine(widthFactor: 0.9, height: 12),
          ],
        ),
      ),
    );
  }
}

class _LoadingSkeletonCard extends StatelessWidget {
  const _LoadingSkeletonCard({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SkeletonLine(widthFactor: 0.4, height: 16),
        SizedBox(height: 12),
        _SkeletonLine(widthFactor: 0.8, height: 12),
        SizedBox(height: 8),
        _SkeletonLine(widthFactor: 0.68, height: 12),
      ],
    );
  }
}
