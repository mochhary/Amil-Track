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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SoftSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: BorderRadius.circular(34),
        highlightAlignment: Alignment.topCenter,
        highlightRadius: 1.2,
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
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.emerald.withValues(alpha: 0.95)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
