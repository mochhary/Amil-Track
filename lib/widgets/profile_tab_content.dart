import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../utils/dialog_utils.dart'; // IMPORT DIALOG UTILS BARU
import 'soft_surface_card.dart';
import 'glass_container.dart';

class ProfileTabContent extends StatefulWidget {
  final String username;
  final String? email;
  final int totalMuzakkiCount;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;
  final Function(String) onUpdateProfile;
  final VoidCallback onShowTutorial;

  const ProfileTabContent({
    super.key,
    required this.username,
    required this.email,
    required this.totalMuzakkiCount,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onUpdateProfile,
    required this.onShowTutorial,
  });

  @override
  State<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<ProfileTabContent> {
  bool _working = false;

  void _showDeleteModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Hapus Akun Permanen?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tindakan ini tidak bisa dibatalkan. Seluruh data lokal Anda akan dibersihkan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      widget.onDeleteAccount();
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.emeraldDeep, AppColors.emerald],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: const Icon(
                  Icons.badge_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amil Terverifikasi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email ?? 'amil@amiltrack.com',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Statistik Personal',
            style: TextStyle(
              color: AppColors.emeraldDeep,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SoftSurfaceCard(
          backgroundColor: Colors.white.withOpacity(0.9),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orangeGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  color: AppColors.orangeGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.totalMuzakkiCount} Jiwa',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Total Muzakki Terlayani',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pengaturan & Bantuan',
            style: TextStyle(
              color: AppColors.emeraldDeep,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SoftSurfaceCard(
          backgroundColor: Colors.white.withOpacity(0.9),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildMenuTile(
                Icons.edit_document,
                Colors.blue.shade700,
                'Edit Data Profil',
                'Perbarui nama identitas amil Anda',
                () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => EditProfileModal(
                      currentName: widget.username,
                      onSave: widget.onUpdateProfile,
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildMenuTile(
                Icons.help_outline_rounded,
                Colors.orange.shade700,
                'Panduan Aplikasi',
                'Lihat ulang tutorial cara penggunaan',
                widget.onShowTutorial,
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildMenuTile(
                Icons.support_agent_rounded,
                Colors.indigo,
                'Hotline Dewan Syariah',
                'Konsultasi kasus fikih via WhatsApp',
                // MENGGUNAKAN DIALOG UTILS DISINI
                () => DialogUtils.launchWithConfirmation(
                  context,
                  'https://wa.me/628123456789?text=Assalamu%27alaikum...',
                  'Buka WhatsApp',
                  'Anda akan dialihkan ke WhatsApp untuk chat dengan Hotline Syariat. Lanjutkan?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: const Text(
            'Logout Sistem',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _working
              ? null
              : () async {
                  setState(() => _working = true);
                  try {
                    await widget.onLogout();
                  } finally {
                    if (mounted) setState(() => _working = false);
                  }
                },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text(
            'Hapus Akun Permanen',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _working ? null : _showDeleteModal,
        ),
      ],
    );
  }
}

class EditProfileModal extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;
  const EditProfileModal({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
        backgroundColor: AppColors.emeraldDeep.withOpacity(0.85),
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
              'Edit Data Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'Perbarui informasi identitas amil Anda',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                labelText: 'Nama Lengkap Baru',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                ),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  widget.onSave(newName);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                }
              },
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
