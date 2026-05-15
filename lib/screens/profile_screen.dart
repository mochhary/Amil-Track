import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/auth_service.dart';
import '../widgets/amil_track_logo.dart';
import '../widgets/soft_surface_card.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final String? username = user?.userMetadata?['username'];

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SoftSurfaceCard(
              backgroundColor: Colors.white,
              child: Row(
                children: [
                  const AmilTrackLogo(size: 80, showTitle: false),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username ?? 'Petugas Amil',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.emeraldDeep,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Tidak diketahui',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SoftSurfaceCard(
              backgroundColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Akun & Akses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.emeraldDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pengaturan, logout, dan penghapusan akun dikelola dari halaman pengaturan.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('Buka Pengaturan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
