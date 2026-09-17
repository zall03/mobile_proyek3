import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await _tryInitFirebase();
  runApp(const DapurCerdasApp());
}

Future<void> _tryInitFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase] init gagal, lanjut tanpa Firebase: $e');
  }
}

class DapurCerdasApp extends StatelessWidget {
  const DapurCerdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dapur Cerdas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}