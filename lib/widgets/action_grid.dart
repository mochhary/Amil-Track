import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import 'glass_container.dart';

// Helper Dialog Mandiri khusus untuk Action Grid
Future<void> launchExternalUrlWithConfirmation(
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.emeraldDeep, fontSize: 18)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Ya, Lanjutkan', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    ),
  );
  if (confirm == true) {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka tautan eksternal.')));
      }
    }
  }
}

class ActionGrid extends StatelessWidget {
  final int todayMuzakki;
  final double todayUang;

  const ActionGrid({
    super.key,
    required this.todayMuzakki,
    required this.todayUang,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BeautifulActionTile(
            icon: Icons.insights_rounded,
            title: 'Cek\nNisab',
            iconColor: Colors.purple,
            bgColor: Colors.purple.withValues(alpha: 0.08),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const NisabModal(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BeautifulActionTile(
            icon: Icons.share_rounded,
            title: 'Kirim\nRekap',
            iconColor: Colors.blue.shade700,
            bgColor: Colors.blue.withValues(alpha: 0.08),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => RekapHarianModal(muzakki: todayMuzakki, uang: todayUang),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BeautifulActionTile(
            icon: Icons.menu_book_rounded,
            title: 'Panduan\nFikih',
            iconColor: Colors.teal,
            bgColor: Colors.teal.withValues(alpha: 0.08),
            onTap: () => launchExternalUrlWithConfirmation(
              context,
              'https://baznas.go.id',
              'Buka Situs BAZNAS',
              'Anda akan diarahkan ke browser luar untuk melihat panduan resmi. Lanjutkan?',
            ),
          ),
        ),
      ],
    );
  }
}

class BeautifulActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const BeautifulActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NisabModal extends StatelessWidget {
  const NisabModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassContainer(
        width: double.infinity,
        borderRadius: 28,
        padding: const EdgeInsets.all(28),
        backgroundColor: AppColors.emeraldDeep.withValues(alpha: 0.85),
        glassOpacity: 0.9,
        blur: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Informasi Nisab & Ketetapan', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            const Text('Standar acuan yang berlaku saat ini', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
              child: Column(
                children: [
                  _buildInfoRow('Zakat Fitrah', 'Rp 40.000 / 2.5 Kg'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12, height: 1)),
                  _buildInfoRow('Zakat Profesi', 'Rp 6.859.394 / Bln'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12, height: 1)),
                  _buildInfoRow('Zakat Maal', 'Rp 82.312.725 / Thn'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12, height: 1)),
                  _buildInfoRow('Fidyah', 'Rp 60.000 / Hari'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class RekapHarianModal extends StatelessWidget {
  final int muzakki;
  final double uang;

  const RekapHarianModal({super.key, required this.muzakki, required this.uang});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 28,
      padding: const EdgeInsets.all(28),
      backgroundColor: AppColors.emeraldDeep.withValues(alpha: 0.85),
      glassOpacity: 0.9,
      blur: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('Rekapitulasi Hari Ini', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Total perolehan selama Anda bertugas hari ini.', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Muzakki', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('$muzakki Jiwa', style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w900)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12, height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dana Terhimpun', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(uang),
                      style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text('Kirim Laporan ke WhatsApp', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              launchExternalUrlWithConfirmation(
                context,
                'https://wa.me/?text=Laporan%20Rekap%20Harian%0AMuzakki:%20$muzakki%20Jiwa%0ADana:%20Rp%20$uang',
                'Bagikan via WhatsApp',
                'Buka WhatsApp untuk membagikan laporan singkat ini ke Koordinator?',
              );
            },
          ),
        ],
      ),
    );
  }
}