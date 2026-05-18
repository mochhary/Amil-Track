// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../services/sqlite_service.dart';

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

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();

  final _jiwaController = TextEditingController(text: '1');
  final _gajiController = TextEditingController();
  final _bonusController = TextEditingController();
  final _hartaController = TextEditingController();
  final _hariController = TextEditingController();

  String _selectedKategori = 'Fitrah';
  String _tipeSatuanFitrah = 'uang';
  double _calculatedJumlah = 0.0;
  bool _isSaving = false;

  final double _hargaBerasPerKg = 16000.0;
  final double _tarifFidyahPerHari = 60000.0;
  final double _nisabProfesiBulanan = 6859394.0;

  @override
  void initState() {
    super.initState();
    _calculateZakatLive();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _jiwaController.dispose();
    _gajiController.dispose();
    _bonusController.dispose();
    _hartaController.dispose();
    _hariController.dispose();
    super.dispose();
  }

  void _calculateZakatLive() {
    setState(() {
      if (_selectedKategori == 'Fitrah') {
        final String rawJiwa = _jiwaController.text.replaceAll('.', '');
        final int jiwa = int.tryParse(rawJiwa) ?? 0;
        if (_tipeSatuanFitrah == 'beras') {
          _calculatedJumlah = jiwa * 2.5;
        } else {
          _calculatedJumlah = jiwa * 2.5 * _hargaBerasPerKg;
        }
      } else if (_selectedKategori == 'Profesi') {
        final String rawGaji = _gajiController.text.replaceAll('.', '');
        final String rawBonus = _bonusController.text.replaceAll('.', '');
        final double gaji = double.tryParse(rawGaji) ?? 0.0;
        final double bonus = double.tryParse(rawBonus) ?? 0.0;
        final double totalPendapatan = gaji + bonus;

        if (totalPendapatan >= _nisabProfesiBulanan) {
          _calculatedJumlah = totalPendapatan * 0.025;
        } else {
          _calculatedJumlah = 0.0;
        }
      } else if (_selectedKategori == 'Maal') {
        final String rawHarta = _hartaController.text.replaceAll('.', '');
        final double harta = double.tryParse(rawHarta) ?? 0.0;
        if (harta >= 82312725.0) {
          _calculatedJumlah = harta * 0.025;
        } else {
          _calculatedJumlah = 0.0;
        }
      } else if (_selectedKategori == 'Fidyah') {
        final String rawHari = _hariController.text.replaceAll('.', '');
        final int hari = int.tryParse(rawHari) ?? 0;
        _calculatedJumlah = hari * _tarifFidyahPerHari;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tolong lengkapi inputan wajib!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_calculatedJumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedKategori == 'Profesi' || _selectedKategori == 'Maal'
                ? 'Pendapatan/aset belum mencapai batas nisab wajib zakat.'
                : 'Jumlah nominal transaksi tidak valid.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = await SqliteService.instance.database;

      int? jumlahJiwaData;
      if (_selectedKategori == 'Fitrah') {
        final String rawJiwa = _jiwaController.text.replaceAll('.', '');
        jumlahJiwaData = int.tryParse(rawJiwa) ?? 1;
      }

      final Map<String, dynamic> txRow = {
        SqliteService.columnNamaMuzakki: _namaController.text.trim(),
        SqliteService.columnKategoriZakat: _selectedKategori,
        SqliteService.columnJumlah: _calculatedJumlah,
        SqliteService.columnTipeSatuan: _selectedKategori == 'Fitrah'
            ? _tipeSatuanFitrah
            : 'uang',
        SqliteService.columnJumlahJiwa: jumlahJiwaData,
        SqliteService.columnCreatedAt: DateTime.now().toIso8601String(),
        SqliteService.columnSyncStatus: 0,
      };

      await db.insert(SqliteService.tableTransactions, txRow);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi Berhasil Dicatat & Disinkronisasi!'),
            backgroundColor: AppColors.emeraldDeep,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.softSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Input Setoran Zakat',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.emeraldDeep,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.emeraldDeep,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identitas Pembayar (Muzakki)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.emeraldDeep,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama muzakki tidak boleh kosong'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Muzakki *',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      filled: true,
                      fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp (Opsional)',
                      prefixIcon: const Icon(Icons.phone_iphone_rounded),
                      filled: true,
                      fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Pilih Kategori Zakat',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.emeraldDeep,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Fitrah', 'Profesi', 'Maal', 'Fidyah'].map((kat) {
                final bool isSelected = _selectedKategori == kat;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(
                        kat,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.emeraldDeep,
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedKategori = kat;
                            _calculatedJumlah = 0.0;
                          });
                          _calculateZakatLive();
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Perhitungan $_selectedKategori',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.emeraldDeep,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_selectedKategori == 'Fitrah') ...[
                    TextFormField(
                      controller: _jiwaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Jumlah jiwa wajib diisi'
                          : null,
                      onChanged: (v) => _calculateZakatLive(),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Jiwa (Tanggungan) *',
                        prefixIcon: const Icon(Icons.people_outline_rounded),
                        filled: true,
                        fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Metode Pembayaran Fitrah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              'Uang tunai',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: 'uang',
                            groupValue: _tipeSatuanFitrah,
                            activeColor: AppColors.emeraldDeep,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) {
                              setState(() => _tipeSatuanFitrah = v!);
                              _calculateZakatLive();
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              'Beras murni',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: 'beras',
                            groupValue: _tipeSatuanFitrah,
                            activeColor: AppColors.emeraldDeep,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) {
                              setState(() => _tipeSatuanFitrah = v!);
                              _calculateZakatLive();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (_selectedKategori == 'Profesi') ...[
                    TextFormField(
                      controller: _gajiController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Gaji pokok wajib diisi'
                          : null,
                      onChanged: (v) => _calculateZakatLive(),
                      decoration: InputDecoration(
                        labelText: 'Gaji Pokok Bulanan (Rp) *',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        filled: true,
                        fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bonusController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      onChanged: (v) => _calculateZakatLive(),
                      decoration: InputDecoration(
                        labelText: 'Tunjangan / Bonus Lainnya (Rp)',
                        prefixIcon: const Icon(Icons.add_card_rounded),
                        filled: true,
                        fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],

                  if (_selectedKategori == 'Maal') ...[
                    TextFormField(
                      controller: _hartaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nilai harta wajib diisi'
                          : null,
                      onChanged: (v) => _calculateZakatLive(),
                      decoration: InputDecoration(
                        labelText: 'Total Nilai Harta Simpanan (Rp) *',
                        prefixIcon: const Icon(Icons.account_balance_rounded),
                        helperText:
                            'Meliputi tabungan, emas mengendap selama 1 tahun haul.',
                        filled: true,
                        fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],

                  if (_selectedKategori == 'Fidyah') ...[
                    TextFormField(
                      controller: _hariController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Jumlah hari wajib diisi'
                          : null,
                      onChanged: (v) => _calculateZakatLive(),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Hari Utang Puasa *',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        filled: true,
                        fillColor: AppColors.softSurface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                        color: AppColors.emerald.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedKategori == 'Fitrah' &&
                                  _tipeSatuanFitrah == 'beras'
                              ? Icons.rice_bowl_rounded
                              : Icons.auto_awesome_rounded,
                          color: AppColors.gold,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIVE PREVIEW WAJIB BAYAR',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedKategori == 'Fitrah' &&
                                      _tipeSatuanFitrah == 'beras'
                                  ? '${_calculatedJumlah.toStringAsFixed(1)} Kg Beras'
                                  : currencyFormat.format(_calculatedJumlah),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (_selectedKategori == 'Profesi' &&
                                _calculatedJumlah == 0.0) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Belum mencapai nisab harian/bulanan.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(target: _calculatedJumlah > 0 ? 1 : 0)
                .shimmer(duration: 1200.ms),
            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldDeep,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : _submitForm,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Catat & Simpan Setoran',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
