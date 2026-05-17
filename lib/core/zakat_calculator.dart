import 'package:flutter/foundation.dart';

class ZakatCalculator {
  // Batas persentase zakat maal & profesi menurut syariat
  static const double zakatRateMultiplier = 0.025; // 2.5%

  // ============================================================================
  // 1. ALGORITMA ZAKAT FITRAH (STANDAR BAZNAS)
  // ============================================================================
  /// Menghitung total kewajiban Zakat Fitrah baik berupa beras (Kg) maupun uang (Rp)
  /// Rumus: Jumlah Jiwa x Nisab Per Jiwa (Beras: 2.5 Kg atau Uang: Harga Beras x 2.5)
  static Map<String, dynamic> calculateFitrah({
    required int jumlahJiwa,
    required double hargaBerasAcuan, 
    required bool bayarPakaiUang,
  }) {
    if (jumlahJiwa <= 0) {
      return {'total': 0.0, 'satuan': bayarPakaiUang ? 'Rp' : 'Kg'};
    }

    // Standar BAZNAS: Nisab per jiwa adalah 2.5 Kg beras
    const double nisabBerasPerJiwa = 2.5; 

    if (bayarPakaiUang) {
      final double totalUang = jumlahJiwa * nisabBerasPerJiwa * hargaBerasAcuan;
      return {'total': totalUang, 'satuan': 'Rp'};
    } else {
      final double totalBeras = jumlahJiwa * nisabBerasPerJiwa;
      return {'total': totalBeras, 'satuan': 'Kg'};
    }
  }

  // ============================================================================
  // 2. ALGORITMA ZAKAT PROFESI / PENGHASILAN (STANDAR BAZNAS)
  // ============================================================================
  /// Menghitung zakat profesi berdasarkan pendapatan bulanan atau tahunan.
  /// Nisab dihitung dari konversi nilai emas 85 gram.
  /// Jika pendapatan >= nisab, wajib zakat 2.5%. Jika tidak, nilainya 0.
  static Map<String, dynamic> calculateProfesi({
    required double pendapatanPerBulan,
    required double bonusAtauLainnya,
    required double hargaEmasPerGramAcuan,
  }) {
    final double totalPendapatanKotor = pendapatanPerBulan + bonusAtauLainnya;
    
    // Standar BAZNAS: Nisab tahunan = 85 gram emas. Nisab bulanan = (85 gram / 12 bulan)
    final double nisabBulananUang = (85 * hargaEmasPerGramAcuan) / 12;

    final bool wajibZakat = totalPendapatanKotor >= nisabBulananUang;
    final double totalZakat = wajibZakat ? (totalPendapatanKotor * zakatRateMultiplier) : 0.0;

    return {
      'isWajib': wajibZakat,
      'nisabKontemporer': nisabBulananUang,
      'totalZakat': totalZakat,
    };
  }

  // ============================================================================
  // 3. ALGORITMA ZAKAT MAAL / HARTA SIMPANAN (STANDAR BAZNAS)
  // ============================================================================
  /// Menghitung zakat maal untuk harta simpanan (tabungan, emas, perhiasan, investasi).
  /// Syarat mutlak: Wajib memenuhi Haul (mengendap 1 tahun) dan mencapai Nisab (85g emas).
  static Map<String, dynamic> calculateMaal({
    required double totalNilaiAset,
    required bool sudahMemenuhiHaul,
    required double hargaEmasPerGramAcuan,
  }) {
    // Jika belum 1 tahun mengendap, otomatis tidak wajib zakat maal
    if (!sudahMemenuhiHaul) {
      return {
        'isWajib': false,
        'alasan': 'Belum memenuhi syarat Haul (1 Tahun)',
        'totalZakat': 0.0,
      };
    }

    // Nisab Maal = Nilai total dari 85 gram emas
    final double nisabMaalUang = 85 * hargaEmasPerGramAcuan;

    final bool wajibZakat = totalNilaiAset >= nisabMaalUang;
    final double totalZakat = wajibZakat ? (totalNilaiAset * zakatRateMultiplier) : 0.0;

    return {
      'isWajib': wajibZakat,
      'nisabAset': nisabMaalUang,
      'totalZakat': totalZakat,
      'alasan': wajibZakat ? 'Wajib zakat terwujud' : 'Total aset belum mencapai batas Nisab',
    };
  }
}
