import 'package:flutter/foundation.dart';

/// Konfigurasi lingkungan aplikasi: kredensial Supabase dan alamat backend Go.
class AppConfig {
  AppConfig._();

  static const supabaseUrl = 'https://yjszydzdqqbdrduofutz.supabase.co';

  /// Supabase Auth publishable key (bukan secret key).
  static const supabasePublishableKey =
      'sb_publishable_gr6_td5fkscZb_Wfhk_UwQ_Ujcc4b6g';

  /// Android emulator memetakan host lewat 10.0.2.2, platform lain pakai
  /// loopback langsung.
  static String get apiBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://127.0.0.1:8080/api';
  }

  /// Harus terdaftar di Supabase Auth > URL Configuration dan cocok dengan
  /// intent-filter di AndroidManifest (scheme = applicationId).
  static const oauthRedirect = 'com.example.project3://login-callback';
}
