import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'soft_surface_card.dart';

class CurvedBottomNavigation extends StatelessWidget {
  const CurvedBottomNavigation({
    super.key,
    required this.onHomeTap,
    required this.onProfileTap,
    this.isHomeActive = true,
    this.isProfileActive = false,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onProfileTap;
  final bool isHomeActive;
  final bool isProfileActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SoftSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(30),
        highlightAlignment: Alignment.topCenter,
        highlightRadius: 1.05,
        backgroundColor: AppColors.backgroundWhite.withValues(alpha: 0.9),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              selected: isHomeActive,
              onTap: onHomeTap,
            ),
            const SizedBox(width: 80),
            _NavItem(
              icon: Icons.person_rounded,
              selected: isProfileActive,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.backgroundWhite : AppColors.emeraldDeep;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Container(
              width: double.infinity,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.emerald, AppColors.emeraldDeep],
                      )
                    : null,
                color: selected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.border.withValues(alpha: 0.62),
                ),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}
