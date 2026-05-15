import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/auth_service.dart';
import '../widgets/soft_surface_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _working = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda akan keluar dari perangkat ini. Pastikan semua data sudah tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _working = true);
    try {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        var typedValue = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isMatch = typedValue.trim().toUpperCase() == 'HAPUS AKUN';

            return AlertDialog(
              title: const Text('Hapus akun?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tindakan ini bersifat permanen. Semua data yang terkait akan dihapus dari perangkat dan akun Anda akan ditutup.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Ketik HAPUS AKUN untuk melanjutkan',
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        typedValue = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isMatch ? () => Navigator.of(ctx).pop(true) : null,
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _working = true);
    try {
      await AuthService.instance.deleteAccount();
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus akun: $e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SoftSurfaceCard(
              backgroundColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sesi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.emeraldDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keluar dari perangkat ini jika ingin berpindah akun.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    onPressed: _working ? null : _logout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SoftSurfaceCard(
              backgroundColor: Colors.white,
              borderColor: AppColors.border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Zona Berbahaya',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hapus akun akan menghapus akses dan data aplikasi yang terkait.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Hapus Akun'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    onPressed: _working ? null : _deleteAccount,
                  ),
                ],
              ),
            ),
            if (_working) ...[
              const SizedBox(height: AppSpacing.md),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
