import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'transaction_schema.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  static const String zakatUangSettingKey = 'zakat_uang';
  static const String zakatBerasSettingKey = 'zakat_beras';

  SupabaseClient get _client => Supabase.instance.client;

  Future<String?> getCurrentUsername() async {
    final username = _client.auth.currentUser?.userMetadata?['username']
        ?.toString()
        .trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    return null;
  }

  Future<void> saveCurrentUsername(String username) async {
    if (_client.auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _client.auth.updateUser(
      UserAttributes(data: <String, dynamic>{'username': username}),
    );
  }

  Future<Map<String, dynamic>?> getSettingByKey(String key) async {
    final response = await _client
        .from('settings')
        .select()
        .eq('key', key)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<String?> getSettingValue(String key) async {
    final setting = await getSettingByKey(key);
    final value = setting?['value'];

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  Future<double?> getZakatPrice(String key) async {
    final value = await getSettingValue(key);
    if (value == null || value.isEmpty) {
      return null;
    }

    return double.tryParse(value);
  }

  Future<Map<String, double?>> getCurrentZakatRates() async {
    final results = await Future.wait([
      getZakatPrice(zakatUangSettingKey),
      getZakatPrice(zakatBerasSettingKey),
    ]);

    return <String, double?>{
      zakatUangSettingKey: results[0],
      zakatBerasSettingKey: results[1],
    };
  }

  Future<Map<String, dynamic>?> updateSettingValue({
    required String key,
    required String value,
  }) async {
    final response = await _client
        .from('settings')
        .update({'value': value})
        .eq('key', key)
        .select()
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<void> deleteSetting(String key) async {
    await _client.from('settings').delete().eq('key', key);
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final response = await _client
        .from('zakat_transactions')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, double>> fetchCollectedTotalsByType() async {
    final transactions = await fetchTransactions();
    var totalUang = 0.0;
    var totalBeras = 0.0;

    for (final transaction in transactions) {
      final amount = extractTransactionAmount(transaction);

      final type = extractTransactionType(transaction)?.toLowerCase();
      if (type == 'beras') {
        totalBeras += amount;
      } else {
        totalUang += amount;
      }
    }

    return <String, double>{'uang': totalUang, 'beras': totalBeras};
  }

  Future<Map<String, dynamic>> insertTransaction({
    required String muzakkiName,
    required int jumlahJiwa,
    required String transactionType,
    required double totalAmount,
    String? phoneNumber,
    String? notes,
  }) async {
    final payload = buildLegacyTransactionInsertPayload(
      muzakkiName: muzakkiName,
      jumlahJiwa: jumlahJiwa,
      transactionType: transactionType,
      totalAmount: totalAmount,
    );

    final response = await _client
        .from('zakat_transactions')
        .insert(payload)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<double> fetchTotalCollected() async {
    final transactions = await fetchTransactions();

    return transactions.fold<double>(0.0, (sum, row) {
      return sum + extractTransactionAmount(row);
    });
  }

  String formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }
}
