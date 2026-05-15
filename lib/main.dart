import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'widgets/app_watermark_background.dart';
import 'widgets/loading_states.dart';
import 'screens/home_screen.dart';
import 'core/navigation.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const AmilTrackApp());
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
      routes: {'/': (context) => const _AuthGate()},
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const _AuthGate());
      },
      builder: (context, child) {
        return AppWatermarkBackground(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  Future<String?>? _usernameFuture;

  void _refreshProfileState() {
    setState(() {
      _usernameFuture = SupabaseService.instance.getCurrentUsername();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          _usernameFuture ??= SupabaseService.instance.getCurrentUsername();
          return FutureBuilder<String?>(
            future: _usernameFuture,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: GlassLoadingSplash());
              }

              final username = profileSnapshot.data;
              if (username == null || username.trim().isEmpty) {
                return ProfileSetupScreen(onCompleted: _refreshProfileState);
              }

              return HomeScreen(username: username);
            },
          );
        }
        return const OnboardingScreen();
      },
    );
  }
}
