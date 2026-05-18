import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'widgets/app_watermark_background.dart';
import 'widgets/loading_states.dart';
import 'screens/home_screen.dart';
import 'core/navigation.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';

// TAMBAHAN: Import provider yang baru kita buat di langkah 11.2
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: AmilTrackApp()));
}

class AmilTrackApp extends StatelessWidget {
  const AmilTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
      }, // _AuthGate diubah jadi AuthGate
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const AuthGate());
      },
      builder: (context, child) {
        return AppWatermarkBackground(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

// 1. Ubah menjadi ConsumerWidget agar bisa menggunakan Riverpod
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  // 2. Tambahkan WidgetRef ref di dalam method build
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Pantau status sesi (login/logout) secara reaktif
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      loading: () => const Scaffold(body: GlassLoadingSplash()),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error Auth: $error'))),
      data: (authState) {
        final session = authState.session;

        // Jika belum login, arahkan ke layar Onboarding
        if (session == null) {
          return const OnboardingScreen();
        }

        // 4. Jika sudah login, pantau status profil (username)
        final profileAsync = ref.watch(userProfileProvider);

        return profileAsync.when(
          loading: () => const Scaffold(body: GlassLoadingSplash()),
          error: (error, stack) =>
              Scaffold(body: Center(child: Text('Error Profil: $error'))),
          data: (username) {
            // Jika belum ada username, paksa ke layar setup profil
            if (username == null || username.trim().isEmpty) {
              return ProfileSetupScreen(
                onCompleted: () {
                  // KEAJAIBAN RIVERPOD:
                  // Saat profil di-save, cukup panggil baris ini dan Riverpod
                  // akan otomatis memuat ulang username dari database dan melempar ke Home!
                  ref.invalidate(userProfileProvider);
                },
              );
            }

            // Jika semua aman, masuk ke Beranda!
            return HomeScreen(username: username);
          },
        );
      },
    );
  }
}
