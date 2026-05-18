import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

// 1. Provider untuk mendengarkan perubahan status Sesi (Login/Logout) secara real-time
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// 2. Provider untuk mengambil data Username dari database
final userProfileProvider = FutureProvider<String?>((ref) async {
  // Kita pantau juga authStateProvider, sehingga jika user tiba-tiba logout,
  // data profile ini akan otomatis di-reset menjadi null.
  final authStateAsync = ref.watch(authStateProvider);
  
  // Jika sedang loading atau tidak ada sesi, kembalikan null
  if (authStateAsync.isLoading || authStateAsync.value?.session == null) {
    return null;
  }

  // Jika ada sesi, ambil username dari SupabaseService yang sudah stabil
  return await SupabaseService.instance.getCurrentUsername();
});