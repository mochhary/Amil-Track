import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/zakat_calculator_provider.dart';
import '../widgets/live_preview_card.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final number = int.parse(digitsOnly);
    final newString = NumberFormat.decimalPattern('id').format(number);
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});
  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _waController = TextEditingController(); // NEW: WA Controller
  final _jiwaController = TextEditingController(text: '1');
  final _gajiController = TextEditingController();
  final _bonusController = TextEditingController();
  final _hartaController = TextEditingController();
  final _hariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tambahkan listener agar setiap ketikan otomatis menghitung zakat
    _jiwaController.addListener(_triggerCalculate);
    _gajiController.addListener(_triggerCalculate);
    _bonusController.addListener(_triggerCalculate);
    _hartaController.addListener(_triggerCalculate);
    _hariController.addListener(_triggerCalculate);

    // Hitung awal (default 1 Jiwa Fitrah)
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerCalculate());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _waController.dispose(); // NEW: Dispose WA Controller
    _jiwaController.dispose();
    _gajiController.dispose();
    _bonusController.dispose();
    _hartaController.dispose();
    _hariController.dispose();
    super.dispose();
  }

  // --- FUNGSI TRIGGER KE PROVIDER ---
  void _triggerCalculate() {
    final notifier = ref.read(zakatCalculatorProvider.notifier);
    final kat = ref.read(zakatCalculatorProvider).kategori;

    if (kat == 'Fitrah') {
      final int jiwa =
          int.tryParse(_jiwaController.text.replaceAll('.', '')) ?? 0;
      notifier.calculateFitrah(jiwa);
    } else if (kat == 'Profesi') {
      final double total =
          (double.tryParse(_gajiController.text.replaceAll('.', '')) ?? 0.0) +
          (double.tryParse(_bonusController.text.replaceAll('.', '')) ?? 0.0);
      notifier.calculateProfesi(total);
    } else if (kat == 'Maal') {
      final double harta =
          double.tryParse(_hartaController.text.replaceAll('.', '')) ?? 0.0;
      notifier.calculateMaal(harta);
    } else if (kat == 'Fidyah') {
      final int hari =
          int.tryParse(_hariController.text.replaceAll('.', '')) ?? 0;
      notifier.calculateFidyah(hari);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(zakatCalculatorProvider);
    if (state.calculatedJumlah <= 0) return;

    final success = await ref
        .read(zakatCalculatorProvider.notifier)
        .saveTransaction(
          namaMuzakki: _namaController.text.trim(),
          nomorWhatsapp: _waController.text.trim(),
          jumlahJiwa: state.kategori == 'Fitrah'
              ? int.tryParse(_jiwaController.text.replaceAll('.', ''))
              : null,
        );

    if (success && mounted) {
      Navigator.pop(context, true); // Kembali ke Beranda & trigger refresh
    }
  }

  // --- FUNGSI HELPER UI ---
  String _getCategoryInfo(String kategori) {
    switch (kategori) {
      case 'Fitrah':
        return 'Zakat yang diwajibkan atas setiap jiwa baik lelaki dan perempuan muslim yang dilakukan pada bulan Ramadhan.';
      case 'Profesi':
        return 'Zakat yang dikenakan pada tiap pekerjaan atau keahlian profesional yang telah mencapai nisab.';
      case 'Maal':
        return 'Zakat atas harta yang dimiliki secara penuh dan telah mencapai nisab serta haul (1 tahun).';
      case 'Fidyah':
        return 'Denda yang wajib dibayar karena meninggalkan puasa wajib dengan alasan yang dibenarkan syariat.';
      default:
        return '';
    }
  }

  Widget _buildCategoryChip(String label, IconData icon, ZakatState state, ZakatCalculatorNotifier notifier) {
    final isSelected = state.kategori == label;
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : AppColors.emeraldDeep,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.emeraldDeep,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.border,
        ),
      ),
      onSelected: (val) {
        if (val) {
          notifier.setKategori(label);
          _triggerCalculate();
        }
      },
    );
  }

  Widget _buildSatuanCard(String title, String subtitle, IconData icon, String value, String groupValue, Function(String) onChanged) {
    final isSelected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emeraldDeep.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.emeraldDeep : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: isSelected ? AppColors.emeraldDeep : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.emeraldDeep : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.emeraldDeep, size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI RENDERER ---
  @override
  Widget build(BuildContext context) {
    // Pantau state kalkulator secara reaktif
    final zakatState = ref.watch(zakatCalculatorProvider);
    final notifier = ref.read(zakatCalculatorProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.softSurface,
      appBar: AppBar(
        title: const Text(
          'Input Setoran Zakat',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. INPUT IDENTITAS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Nama Muzakki wajib diisi'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Muzakki *',
                      prefixIcon: const Icon(
                        Icons.person_rounded,
                        color: AppColors.emeraldDeep,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.softSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _waController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp (Opsional)',
                      hintText: 'Contoh: 0812...',
                      prefixIcon: const Icon(
                        Icons.phone_rounded,
                        color: AppColors.emeraldDeep,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.softSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. PILIHAN KATEGORI
            const Text(
              'Kategori Setoran',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('Fitrah', Icons.rice_bowl_rounded, zakatState, notifier),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Profesi', Icons.work_rounded, zakatState, notifier),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Maal', Icons.monetization_on_rounded, zakatState, notifier),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Fidyah', Icons.restaurant_rounded, zakatState, notifier),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Informasi Kategori
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emeraldDeep.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emeraldDeep.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.emeraldDeep, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getCategoryInfo(zakatState.kategori),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.emeraldDeep,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. DYNAMIC FIELDS (Berdasarkan Kategori)
            if (zakatState.kategori == 'Fitrah') ...[
              Row(
                children: [
                  _buildSatuanCard(
                    'Beras (Kg)',
                    'Setara 2.5 kg atau 3.5 liter beras',
                    Icons.rice_bowl_rounded,
                    'beras',
                    zakatState.tipeSatuanFitrah,
                    (val) {
                      notifier.setTipeSatuanFitrah(val);
                      _triggerCalculate();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildSatuanCard(
                    'Uang (Rp)',
                    'Sesuai SK BAZNAS daerah',
                    Icons.payments_rounded,
                    'uang',
                    zakatState.tipeSatuanFitrah,
                    (val) {
                      notifier.setTipeSatuanFitrah(val);
                      _triggerCalculate();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jiwaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Jumlah Jiwa',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ] else if (zakatState.kategori == 'Profesi') ...[
              TextFormField(
                controller: _gajiController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Pendapatan Pokok / Bulan (Rp)',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bonusController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Bonus / THR (Opsional)',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ] else if (zakatState.kategori == 'Maal') ...[
              TextFormField(
                controller: _hartaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Total Harta Tersimpan (Emas/Uang/Aset)',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ] else if (zakatState.kategori == 'Fidyah') ...[
              TextFormField(
                controller: _hariController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Jumlah Hari Ditinggalkan',
                  suffixText: 'Hari',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 4. LIVE PREVIEW CARD REAKTIF
            LivePreviewCard(
              kategori: zakatState.kategori,
              tipeSatuan: zakatState.tipeSatuanFitrah,
              jumlah: zakatState.calculatedJumlah,
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldDeep,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: zakatState.isSaving ? null : _submitForm,
              child: zakatState.isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Simpan Data Setoran',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 40), // Jarak bawah layar
          ],
        ),
      ),
    );
  }
}
