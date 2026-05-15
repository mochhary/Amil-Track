import 'package:flutter/material.dart';

import '../core/constants.dart';

class AmilTrackLogo extends StatelessWidget {
  const AmilTrackLogo({
    super.key,
    this.size = 132,
    this.showTitle = true,
    this.titleStyle,
  });

  static const String _assetPath =
      'assets/images/logo_amil_track_transparant.png';

  final double size;
  final bool showTitle;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final title =
        titleStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.backgroundWhite,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 1.18,
          child: Image.asset(
            _assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text('Amil Track', style: title, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
