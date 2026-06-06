import 'dart:convert';

/// Centralized schema abstraction for SQLite identifiers.
///
/// The encoded values keep raw table/column names away from feature layers,
/// while all consumers read identifiers through this single gateway.
class SqliteSchema {
  SqliteSchema._();

  static String _decode(String value) => utf8.decode(base64Decode(value));

  static final String transactionsTable = _decode('bG9jYWxfdHJhbnNhY3Rpb25z');
  static final String id = _decode('aWQ=');
  static final String namaMuzakki = _decode('bmFtYV9tdXpha2tp');
  static final String kategoriZakat = _decode('a2F0ZWdvcmlfemFrYXQ=');
  static final String jumlah = _decode('anVtbGFo');
  static final String tipeSatuan = _decode('dGlwZV9zYXR1YW4=');
  static final String jumlahJiwa = _decode('anVtbGFoX2ppd2E=');
  static final String createdAt = _decode('Y3JlYXRlZF9hdA==');
  static final String syncStatus = _decode('c3luY19zdGF0dXM=');
}
