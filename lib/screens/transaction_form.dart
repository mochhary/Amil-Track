// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/constants.dart';
import '../core/navigation.dart';
import '../services/supabase_service.dart';
import '../widgets/soft_surface_card.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'uang';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _jumlahController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) return null;

    if (_type == 'beras') {
      return double.tryParse(raw.replaceAll(',', '.'));
    }

    return double.tryParse(raw.replaceAll(',', ''));
  }

  String _amountLabel() {
    return _type == 'beras' ? 'Jumlah Zakat Beras' : 'Nominal Zakat Uang';
  }

  String _amountHint() {
    return _type == 'beras' ? 'Contoh: 2,5' : 'Contoh: 150000';
  }

  String _amountHelper() {
    return _type == 'beras'
        ? 'Gunakan koma untuk desimal, misalnya 2,5'
        : 'Gunakan angka tanpa titik, misalnya 150000';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final navContext = appNavigatorKey.currentContext;

    final name = _nameController.text.trim();
    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 1;
    final amount = _parseAmount() ?? 0;
    final phone = _phoneController.text.trim();
    final notes = _notesController.text.trim();

    try {
      await SupabaseService.instance.insertTransaction(
        muzakkiName: name,
        jumlahJiwa: jumlah,
        transactionType: _type,
        totalAmount: amount,
        phoneNumber: phone.isEmpty ? null : phone,
        notes: notes.isEmpty ? null : notes,
      );

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navContext = appNavigatorKey.currentContext;
        if (navContext == null) return;
        showDialog<bool>(
          context: navContext,
          builder: (ctx) => AlertDialog(
            title: const Text('Zakat Disimpan'),
            content: const Text('Zakat berhasil disimpan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Kirim via WhatsApp'),
              ),
            ],
          ),
        ).then((shouldShare) {
          if (shouldShare == true) {
            _shareWhatsApp();
            // After sharing, close the form and signal success
            appNavigatorKey.currentState?.pop(true);
          } else {
            appNavigatorKey.currentState?.pop(true);
          }
        });
      });
    } catch (e) {
      if (navContext == null) return;
      ScaffoldMessenger.of(
        navContext,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan zakat: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _shareWhatsApp() async {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();
    final text = Uri.encodeComponent(
      'Halo, terima kasih. Bukti setoran zakat:\nNama: $name\nJumlah: $amount',
    );
    final url = 'https://wa.me/?text=$text';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      final navContext = appNavigatorKey.currentContext;
      if (navContext != null) {
        ScaffoldMessenger.of(navContext).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Zakat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SoftSurfaceCard(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Input Zakat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.emeraldDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Masukkan data zakat dengan format yang sesuai satuan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Muzakki'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Masukkan nama' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Jiwa',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null)
                            ? 'Masukkan angka'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _type,
                        items: const [
                          DropdownMenuItem(value: 'uang', child: Text('Uang')),
                          DropdownMenuItem(
                            value: 'beras',
                            child: Text('Beras'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? 'uang'),
                        decoration: const InputDecoration(labelText: 'Jenis'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey(_type),
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: _amountLabel(),
                    hintText: _amountHint(),
                    prefixText: _type == 'uang' ? 'Rp ' : null,
                    suffixText: _type == 'beras' ? 'Kg' : null,
                  ),
                  keyboardType: _type == 'beras'
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  validator: (v) {
                    final parsed = _parseAmount();
                    if (v == null || v.trim().isEmpty || parsed == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _amountHelper(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor telepon (opsional)',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text('Simpan Zakat'),
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
