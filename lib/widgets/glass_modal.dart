import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart'; // Untuk memanggil AppColors
import 'glass_container.dart';

/// Fungsi helper agar Pop-Up premium ini mudah dipanggil dari layar manapun
Future<T?> showGlassModal<T>({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  Color iconColor = AppColors.emerald,
  required String primaryButtonText,
  required VoidCallback onPrimaryPressed,
  String? secondaryButtonText,
  VoidCallback? onSecondaryPressed,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'GlassModal',
    barrierColor: Colors.black.withValues(alpha: 0.4), // Latar belakang gelap di belakang pop-up
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Efek muncul memantul (Ease Out Back)
      final curvedValue = Curves.easeOutBack.transform(animation.value);
      return Transform.scale(
        scale: curvedValue,
        child: Opacity(
          opacity: animation.value,
          child: AlertDialog(
            backgroundColor: Colors.transparent, // Transparan agar GlassContainer terlihat
            contentPadding: EdgeInsets.zero,
            elevation: 0,
            content: _GlassModalContent(
              title: title,
              message: message,
              icon: icon,
              iconColor: iconColor,
              primaryButtonText: primaryButtonText,
              onPrimaryPressed: onPrimaryPressed,
              secondaryButtonText: secondaryButtonText,
              onSecondaryPressed: onSecondaryPressed,
            ),
          ),
        ),
      );
    },
  );
}

/// Isi dari Modal Premium
class _GlassModalContent extends StatelessWidget {
  const _GlassModalContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.maxFinite,
      padding: const EdgeInsets.all(32),
      borderRadius: 32, // Radius melengkung ekstrem gaya premium
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      glassOpacity: 0.6,
      blur: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon Animasi
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: iconColor),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 24),

          // Judul
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.emeraldDeep,
            ),
          ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 12),

          // Pesan / Deskripsi
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),

          // Tombol Aksi
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  primaryButtonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (secondaryButtonText != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    secondaryButtonText!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ).animate().fade(delay: 500.ms),
        ],
      ),
    );
  }
}