import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../welcome/presentation/pages/welcome_page.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const int _segmentCount = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      final destination = session == null
          ? const WelcomePage()
          : HomePage(userName: _displayName(session.user));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    });
  }

  /// Nama tampilan awal dari metadata sesi; halaman profil menyegarkan dari API.
  String _displayName(User user) {
    final metaName = user.userMetadata?['name'] as String?;
    if (metaName != null && metaName.trim().isNotEmpty) return metaName.trim();
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Pengguna';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Logo placeholder — ganti dengan Image.asset('assets/logo.png')
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryDark, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Dapur Cerdas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Solusi Masak Cerdas,\nCegah Stunting, & Gizi Terjaga',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const Spacer(flex: 4),
                _SegmentedLoader(
                  controller: _controller,
                  segments: _segmentCount,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loader berbentuk deretan segmen yang menyala berurutan,
/// meniru progress bar bersegmen di desain (hijau muda -> hijau tua).
class _SegmentedLoader extends StatelessWidget {
  final AnimationController controller;
  final int segments;

  const _SegmentedLoader({required this.controller, required this.segments});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 8),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(segments, (index) {
              final segmentProgress = (controller.value * segments - index)
                  .clamp(0.0, 1.0);
              final color = Color.lerp(
                AppColors.primaryLight.withValues(alpha: 0.25),
                AppColors.primaryDark,
                segmentProgress,
              );
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 18,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
