import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'Amil Track';

  static String get supabaseUrl => _requiredEnv('SUPABASE_URL');
  static String get supabaseAnonKey => _requiredEnv('SUPABASE_ANON_KEY');

  static String _requiredEnv(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable: $key. '
        'Please configure it in .env file.',
      );
    }
    return value;
  }
}

class AppColors {
  const AppColors._();

  static const Color emerald = Color(0xFF1F6B4D);
  static const Color emeraldDeep = Color(0xFF154D39);
  static const Color emeraldMuted = Color(0xFF5F8F79);
  static const Color gold = Color(0xFFC8A44D);
  static const Color orangeGold = Color(0xFFD9892B);
  static const Color backgroundWhite = Color(0xFFF6F5EF);
  static const Color watermark = Color(0xFFE7ECE3);

  static const Color textPrimary = Color(0xFF1B1C1A);
  static const Color textSecondary = Color(0xFF444841);
  static const Color softSurface = Color(0xFFF0F3ED);
  static const Color surfaceContainer = Color(0xFFE9EEE6);
  static const Color border = Color(0xFFDCE3D8);
  static const Color shadowDark = Color(0x12000000);
  static const Color shadowLight = Color(0x55FFFFFF);

  // Backwards-compatible aliases for existing screens during theme rollout.
  static const Color primaryDarkGreen = emerald;
  static const Color secondaryMutedGreen = emeraldMuted;
  static const Color backgroundBeige = backgroundWhite;
  static const Color accentOrange = orangeGold;
  static const Color surfaceWhite = backgroundWhite;
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}
