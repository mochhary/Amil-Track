import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/zakat_calculator.dart';
import '../widgets/app_watermark_background.dart';
import '../widgets/soft_surface_card.dart';
import '../services/supabase_service.dart';
import '../services/sqlite_service.dart';
import '../services/sync_service.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // FIX: Menambahkan state untuk mengontrol validasi otomatis saat user mengetik
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _namaController = TextEditingController();
  final _keteranganController = TextEditingController();

  final _jumlahJiwaController = TextEditingController(text: '1');
  final _pendapatanController = TextEditingController();
  final _bonusController = TextEditingController();
  final _asetController = TextEditingController();

  String _kategoriZakat = 'Fitrah';
  String _metodePembayaran = 'Tunai';
  String _tipeSatuanFitrah = 'uang';
  bool _sudahMemenuhiHaul = true;

  double _hargaBerasAcuan = 15000;
  double _hargaEmasAcuan = 1400000;

  double _calculatedZakatResult = 0.0;
  bool _isEligibleForZakat = true;
  String _infoNisabText = '';

  String _errorMessageTitle = 'Belum Wajib Zakat';
  String _errorMessageDesc =
      'Aset kotor belum menyentuh batas ambang minimal Nisab.';

  @override
  void initState() {
    super.initState();
    _fetchLatestRates();

    _jumlahJiwaController.addListener(_runLiveCalculator);
    _pendapatanController.addListener(_runLiveCalculator);
    _bonusController.addListener(_runLiveCalculator);
    _asetController.addListener(_runLiveCalculator);

    _runLiveCalculator();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    _jumlahJiwaController.dispose();
    _pendapatanController.dispose();
    _bonusController.dispose();
    _asetController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestRates() async {
    try {
      final rates = await SupabaseService.instance.getCurrentZakatRates();
      setState(() {
        if (rates[SupabaseService.zakatBerasSettingKey] != null) {
          _hargaBerasAcuan = rates[SupabaseService.zakatBerasSettingKey]!;
        }
        _hargaEmasAcuan = 1400000;
      });
      _runLiveCalculator();
    } catch (e) {
      debugPrint('Gagal memuat acuan: $e');
    }
  }

  double _parseClearedValue(String text) {
    final cleaned = text.replaceAll('.', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _runLiveCalculator() {
    setState(() {
      if (_kategoriZakat == 'Fitrah') {
        final int jiwa = int.tryParse(_jumlahJiwaController.text) ?? 0;
        final res = ZakatCalculator.calculateFitrah(
          jumlahJiwa: jiwa,
          hargaBerasAcuan: _hargaBerasAcuan,
          bayarPakaiUang: _tipeSatuanFitrah == 'uang',
        );
        _calculatedZakatResult = res['total'];

        if (jiwa <= 0) {
          _isEligibleForZakat = false;
          _errorMessageTitle = 'Input Jiwa Kosong';
          _errorMessageDesc =
              'Silakan masukkan jumlah jiwa minimal 1 untuk menghitung kewajiban zakat fitrah.';
        } else {
          _isEligibleForZakat = true;
          _infoNisabText = 'Standar BAZNAS: 2.5 Kg atau setara uang per jiwa.';
        }
      } else if (_kategoriZakat == 'Profesi') {
        final double gajih = _parseClearedValue(_pendapatanController.text);
        final double bonus = _parseClearedValue(_bonusController.text);

        final res = ZakatCalculator.calculateProfesi(
          pendapatanPerBulan: gajih,
          bonusAtauLainnya: bonus,
          hargaEmasPerGramAcuan: _hargaEmasAcuan,
        );
        _isEligibleForZakat = res['isWajib'];
        _calculatedZakatResult = res['totalZakat'];
        _infoNisabText =
            'Nisab Bulanan: Rp ${(res['nisabKontemporer'] as double).toStringAsFixed(0)}';

        if (!_isEligibleForZakat) {
          _errorMessageTitle = 'Belum Wajib Zakat';
          _errorMessageDesc = gajih <= 0
              ? 'Silakan masukkan pendapatan kotor bulanan terlebih dahulu.'
              : 'Total pendapatan kotor bulanan belum mencapai batas minimal Nisab profesi.';
        }
      } else if (_kategoriZakat == 'Maal') {
        final double aset = _parseClearedValue(_asetController.text);

        final res = ZakatCalculator.calculateMaal(
          totalNilaiAset: aset,
          sudahMemenuhiHaul: _sudahMemenuhiHaul,
          hargaEmasPerGramAcuan: _hargaEmasAcuan,
        );
        _isEligibleForZakat = res['isWajib'];
        _calculatedZakatResult = res['totalZakat'];
        _infoNisabText =
            'Nisab Maal: Rp ${(res['nisabAset'] as double).toStringAsFixed(0)}';

        if (!_isEligibleForZakat) {
          _errorMessageTitle = 'Belum Wajib Zakat';
          _errorMessageDesc = aset <= 0
              ? 'Silakan masukkan total nilai aset tabungan terlebih dahulu.'
              : (res['alasan'] ??
                    'Total nilai aset simpanan belum menyentuh batas minimal Nisab Maal.');
        }
      }
    });
  }

  Future<void> _submitData() async {
    // FIX: Mengubah mode validasi menjadi interaktif (On User Interaction)
    // jika user mencoba menyimpan form yang salah.
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi kolom yang wajib diisi.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isEligibleForZakat || _calculatedZakatResult <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaksi ditolak! Nominal 0 atau belum memenuhi syarat Nisab.',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String localId = 'TX-${DateTime.now().millisecondsSinceEpoch}';
    final String timestamp = DateTime.now().toIso8601String();

    final Map<String, dynamic> txRow = {
      SqliteService.columnLocalId: localId,
      SqliteService.columnNamaMuzakki: _namaController.text.trim(),
      SqliteService.columnKategoriZakat: _kategoriZakat,
      SqliteService.columnMetodePembayaran: _metodePembayaran,
      SqliteService.columnJumlah: _calculatedZakatResult,
      SqliteService.columnTipeSatuan:
          (_kategoriZakat == 'Fitrah' && _tipeSatuanFitrah == 'beras')
          ? 'beras'
          : 'uang',
      SqliteService.columnKeterangan: _keteranganController.text.trim(),
      SqliteService.columnCreatedAt: timestamp,
      SqliteService.columnSyncStatus: 0,
    };

    try {
      final result = await SqliteService.instance.insertTransaction(txRow);

      if (result != -1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.emeraldDeep,
            ),
          );
        }
        SyncService.instance.syncPendingData();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        throw Exception("Gagal menyimpan ke memori perangkat.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Color _getResultCardColor() {
    if (!_isEligibleForZakat) return Colors.red.shade700;

    switch (_kategoriZakat) {
      case 'Fitrah':
        return AppColors.emeraldDeep;
      case 'Profesi':
        return Colors.orange.shade800;
      case 'Maal':
        return Colors.amber.shade800;
      default:
        return AppColors.emeraldDeep;
    }
  }

  InputDecoration _buildPremiumInputDecoration({
    required String label,
    required IconData prefixIcon,
    bool isCompact = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: isCompact ? 12 : 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 8.0 : 12.0),
        child: Icon(
          prefixIcon,
          color: AppColors.emerald,
          size: isCompact ? 18 : 22,
        ),
      ),
      prefixIconConstraints: isCompact
          ? const BoxConstraints(minWidth: 32, minHeight: 32)
          : null,
      filled: true,
      fillColor: AppColors.softSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16,
        vertical: isCompact ? 12 : 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppWatermarkBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Catat Setoran Zakat'),
        ),
        body: Form(
          key: _formKey,
          // FIX: Menerapkan mode auto validate yang reaktif terhadap ketikan user
          autovalidateMode: _autovalidateMode,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              SoftSurfaceCard(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Pembayar (Muzakki)',
                      style: TextStyle(
                        color: AppColors.emeraldDeep,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: _buildPremiumInputDecoration(
                        label: 'Nama Lengkap Muzakki',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SoftSurfaceCard(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Klasifikasi Syariat Zakat',
                      style: TextStyle(
                        color: AppColors.emeraldDeep,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _kategoriZakat,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      icon: const Icon(
                        Icons.arrow_drop_down_circle_rounded,
                        color: AppColors.emerald,
                      ),
                      decoration: _buildPremiumInputDecoration(
                        label: 'Pilih Kategori Zakat',
                        prefixIcon: Icons.gavel_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Fitrah',
                          child: Text(
                            'Zakat Fitrah',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Profesi',
                          child: Text(
                            'Zakat Profesi',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Maal',
                          child: Text(
                            'Zakat Maal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _kategoriZakat = v;
                            // Reset mode validasi saat pindah kategori agar tidak langsung merah
                            _autovalidateMode = AutovalidateMode.disabled;
                          });
                          _runLiveCalculator();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_kategoriZakat == 'Fitrah') ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _jumlahJiwaController,
                              keyboardType: TextInputType.number,
                              decoration: _buildPremiumInputDecoration(
                                label: 'Jiwa',
                                prefixIcon: Icons.people_alt_rounded,
                                isCompact: true,
                              ),
                              style: const TextStyle(fontSize: 14),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Wajib diisi';
                                if ((int.tryParse(v) ?? 0) <= 0)
                                  return 'Minimal 1';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 6,
                            child: DropdownButtonFormField<String>(
                              value: _tipeSatuanFitrah,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              icon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppColors.emerald,
                              ),
                              decoration: _buildPremiumInputDecoration(
                                label: 'Bentuk Zakat',
                                prefixIcon: Icons.shopping_bag_rounded,
                                isCompact: true,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'uang',
                                  child: Text(
                                    'Uang tunai',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'beras',
                                  child: Text(
                                    'Beras (Makanan)',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _tipeSatuanFitrah = v);
                                  _runLiveCalculator();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_kategoriZakat == 'Profesi') ...[
                      TextFormField(
                        controller: _pendapatanController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: _buildPremiumInputDecoration(
                          label: 'Pendapatan Bersih Bulanan (Rp)',
                          prefixIcon: Icons.payments_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Pendapatan wajib diisi';
                          if (_parseClearedValue(v) <= 0)
                            return 'Tidak boleh 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bonusController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: _buildPremiumInputDecoration(
                          label: 'Bonus / Tunjangan Tambahan (Rp)',
                          prefixIcon: Icons.card_giftcard_rounded,
                        ),
                      ),
                    ],

                    if (_kategoriZakat == 'Maal') ...[
                      TextFormField(
                        controller: _asetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: _buildPremiumInputDecoration(
                          label: 'Total Nilai Aset Tabungan (Rp)',
                          prefixIcon: Icons.account_balance_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Nilai aset wajib diisi';
                          if (_parseClearedValue(v) <= 0)
                            return 'Tidak boleh 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text(
                          'Harta sudah mengendap 1 Tahun (Haul)?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        activeColor: AppColors.emerald,
                        contentPadding: EdgeInsets.zero,
                        value: _sudahMemenuhiHaul,
                        onChanged: (v) {
                          setState(() => _sudahMemenuhiHaul = v);
                          _runLiveCalculator();
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getResultCardColor(),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getResultCardColor().withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'HASIL KALKULASI OTOMATIS SYSTEM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!_isEligibleForZakat) ...[
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessageTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _errorMessageDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ] else ...[
                      Text(
                        _kategoriZakat == 'Fitrah' &&
                                _tipeSatuanFitrah == 'beras'
                            ? '${_calculatedZakatResult.toStringAsFixed(1)} Kg Beras'
                            : SupabaseService.instance.formatCurrency(
                                _calculatedZakatResult,
                              ),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Besaran Wajib Setor Syariat',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.white30,
                      ),
                    ),
                    Text(
                      _infoNisabText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SoftSurfaceCard(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _metodePembayaran,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppColors.emerald,
                      ),
                      decoration: _buildPremiumInputDecoration(
                        label: 'Metode Penyaluran',
                        prefixIcon: Icons.wallet_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Tunai',
                          child: Text('Uang Tunai / Cash'),
                        ),
                        DropdownMenuItem(
                          value: 'Transfer',
                          child: Text('Transfer Bank'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _metodePembayaran = v ?? 'Tunai'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _keteranganController,
                      decoration: _buildPremiumInputDecoration(
                        label: 'Keterangan Tambahan / Doa Muzakki',
                        prefixIcon: Icons.chat_bubble_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _submitData,
                  child: const Text(
                    'Simpan Setoran Zakat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    if (newValue.selection.baseOffset == 0) return newValue;
    try {
      final String cleanedText = newValue.text.replaceAll('.', '').trim();
      final double value = double.parse(cleanedText);
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      );
      String newText = formatter.format(value).trim();
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } catch (e) {
      return oldValue;
    }
  }
}
