import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../utils/dialog_utils.dart';
import 'glass_container.dart';

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
              builder: (ctx) =>
                  RekapHarianModal(muzakki: todayMuzakki, uang: todayUang),
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
            onTap: () => DialogUtils.launchWithConfirmation(
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Informasi Nisab',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Zakat Fitrah', '2.5 Kg'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Zakat Profesi', 'Rp 6.8M / Bln'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: Colors.white70)),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

class RekapHarianModal extends StatelessWidget {
  final int muzakki;
  final double uang;
  const RekapHarianModal({
    super.key,
    required this.muzakki,
    required this.uang,
  });
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(28),
      backgroundColor: AppColors.emeraldDeep.withValues(alpha: 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rekap Hari Ini: $muzakki Jiwa',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => DialogUtils.launchWithConfirmation(
              context,
              'https://wa.me/?text=Rekap:$muzakki, Dana: $uang',
              'Kirim WhatsApp',
              'Bagikan laporan?',
            ),
            child: const Text('Kirim ke WhatsApp'),
          ),
        ],
      ),
    );
  }
}
