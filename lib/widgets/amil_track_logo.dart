import 'package:flutter/material.dart';

class AmilTrackLogo extends StatelessWidget {
  final double size;
  final bool showTitle;

  const AmilTrackLogo({super.key, this.size = 120.0, this.showTitle = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FIX: Tambahkan Flexible agar logo mengecil elegan saat di ruang sempit
        Flexible(
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Image.asset(
                'assets/images/logo_amil_track.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 12),
          const Text(
            'Amil Track',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF064E3B), // AppColors.emeraldDeep
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
