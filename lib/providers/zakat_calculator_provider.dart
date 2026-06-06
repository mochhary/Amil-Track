import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/sqlite_service.dart';

// 1. Model State untuk Form Zakat
class ZakatState {
  final String kategori;
  final String tipeSatuanFitrah;
  final double calculatedJumlah;
  final bool isSaving;

  const ZakatState({
    this.kategori = 'Fitrah',
    this.tipeSatuanFitrah = 'uang',
    this.calculatedJumlah = 0.0,
    this.isSaving = false,
  });

  ZakatState copyWith({
    String? kategori,
    String? tipeSatuanFitrah,
    double? calculatedJumlah,
    bool? isSaving,
  }) {
    return ZakatState(
      kategori: kategori ?? this.kategori,
      tipeSatuanFitrah: tipeSatuanFitrah ?? this.tipeSatuanFitrah,
      calculatedJumlah: calculatedJumlah ?? this.calculatedJumlah,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// 2. Notifier: Otak Matematika & Database
class ZakatCalculatorNotifier extends Notifier<ZakatState> {
  // Konstanta Enterprise (Bisa dipindah ke env/database kelak)
  final double _hargaBerasPerKg = 16000.0;
  final double _tarifFidyahPerHari = 60000.0;
  final double _nisabProfesiBulanan = 6859394.0;
  final double _nisabMaal = 82312725.0;

  @override
  ZakatState build() => const ZakatState();

  // --- FUNGSI UPDATE UI ---
  void setKategori(String kat) {
    state = state.copyWith(kategori: kat, calculatedJumlah: 0.0);
  }

  void setTipeSatuanFitrah(String tipe) {
    state = state.copyWith(tipeSatuanFitrah: tipe);
  }

  // --- FUNGSI KALKULATOR MATEMATIS ---
  void calculateFitrah(int jiwa) {
    double total = state.tipeSatuanFitrah == 'beras'
        ? jiwa * 2.5
        : jiwa * 2.5 * _hargaBerasPerKg;
    state = state.copyWith(calculatedJumlah: total);
  }

  void calculateProfesi(double totalPendapatan) {
    double total = totalPendapatan >= _nisabProfesiBulanan
        ? totalPendapatan * 0.025
        : 0.0;
    state = state.copyWith(calculatedJumlah: total);
  }

  void calculateMaal(double harta) {
    double total = harta >= _nisabMaal ? harta * 0.025 : 0.0;
    state = state.copyWith(calculatedJumlah: total);
  }

  void calculateFidyah(int hari) {
    double total = hari * _tarifFidyahPerHari;
    state = state.copyWith(calculatedJumlah: total);
  }

  // --- FUNGSI PENYIMPANAN DATABASE (ABSTRAKSI) ---
  Future<bool> saveTransaction({
    required String namaMuzakki,
    int? jumlahJiwa,
    String? nomorWhatsapp,
  }) async {
    if (state.calculatedJumlah <= 0) return false;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    state = state.copyWith(isSaving: true);
    try {
      final db = await SqliteService.instance.database;
      await db.insert(SqliteService.tableTransactions, {
        SqliteService.columnNamaMuzakki: namaMuzakki,
        SqliteService.columnKategoriZakat: state.kategori,
        SqliteService.columnJumlah: state.calculatedJumlah,
        SqliteService.columnTipeSatuan: state.kategori == 'Fitrah'
            ? state.tipeSatuanFitrah
            : 'uang',
        SqliteService.columnJumlahJiwa: state.kategori == 'Fitrah'
            ? jumlahJiwa
            : null,
        SqliteService.columnNomorWhatsapp: nomorWhatsapp,
        SqliteService.columnUserId: userId,
        SqliteService.columnCreatedAt: DateTime.now().toIso8601String(),
        SqliteService.columnSyncStatus: 0,
      });
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

// 3. Provider Utama
final zakatCalculatorProvider =
    NotifierProvider<ZakatCalculatorNotifier, ZakatState>(() {
      return ZakatCalculatorNotifier();
    });
