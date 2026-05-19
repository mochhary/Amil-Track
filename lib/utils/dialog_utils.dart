import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class DialogUtils {
  // Mencegah class ini di-instansiasi
  DialogUtils._();

  /// Fungsi universal untuk menampilkan konfirmasi sebelum membuka link eksternal (Browser/WhatsApp)
  static Future<void> launchWithConfirmation(
    BuildContext context,
    String urlString,
    String title,
    String message,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.emeraldDeep,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Lanjutkan',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

    // Jika user menekan 'Ya'
    if (confirm == true) {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka tautan eksternal.')),
          );
        }
      }
    }
  }
}
