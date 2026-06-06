import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sqlite_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.externalApplication,
      redirectTo: kIsWeb ? null : 'io.supabase.amiltrack://login-callback',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Soft-delete account data owned by the current user and sign out.
  ///
  /// Note: Fully deleting an Auth user often requires service-role credentials.
  /// This method removes application rows associated with the user and then
  /// signs out locally.
  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Hapus data online dari Supabase
    await _client.from('zakat_transactions').delete().eq('user_id', user.id);
    
    // Hapus pengaturan user dari Supabase (jika ada) - opsional, jika tidak ada relasi tabel pengaturan
    // await _client.from('settings').delete().eq('user_id', user.id);

    // Hapus data lokal dari SQLite
    await SqliteService.instance.clearUserData(user.id);

    // Logout
    await signOut();
  }

  /// Returns the currently signed-in user, if any.
  User? get currentUser => _client.auth.currentUser;
}
