import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nutrisi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ),
      body: const _NutritionBody(),
    );
  }
}

class _NutritionBody extends StatefulWidget {
  const _NutritionBody();

  @override
  State<_NutritionBody> createState() => _NutritionBodyState();
}

class _NutritionBodyState extends State<_NutritionBody> {
  final String _activePeriod = 'Harian';

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label segera hadir'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      children: [
        _buildHeader(),
        _PeriodTabs(
          active: _activePeriod,
          onTap: (label) {
            if (label != _activePeriod) {
              _showComingSoon(label);
            }
          },
        ),
        const _GiziRingCard(),
        const _SectionLabel('Makronutrisi Harian'),
        const _SectionSub(
          'Target Harian Aktif',
          padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
        ),
        for (final macro in _macros) _MacroCard(macro: macro),
        const SizedBox(height: 18),
        const _MicroSection(),
        const SizedBox(height: 18),
        const _SectionLabel('Riwayat Menu Hari Ini'),
        const SizedBox(height: 12),
        for (final meal in _meals) _MealTile(meal: meal),
        const SizedBox(height: 18),
        const _ExportCard(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analisis Nutrisi Harian',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'R',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rayyan Pratara (18 Bulan)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Target 1.100 kkal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hari Ini, 24 Okt',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  final String active;
  final ValueChanged<String> onTap;

  const _PeriodTabs({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const labels = ['Harian', 'Mingguan', 'Tren Bulanan'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onTap(label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: label == active
                          ? AppColors.primaryDark
                          : AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: label == active
                            ? Colors.white
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GiziRingCard extends StatelessWidget {
  const _GiziRingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Text(
            'CAPAIAN GIZI HARI INI',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Sesuai Standar WHO',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: 0.88,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFE8F5E9),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryMedium),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '88%',
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'GIZI OPTIMAL',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
              children: [
                const TextSpan(text: 'Tingkat Kecukupan Gizi: '),
                TextSpan(
                  text: 'Sangat Baik',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const TextSpan(text: ' (Cegah Stunting)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSub extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const _SectionSub(this.text, {this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 0)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textGrey),
      ),
    );
  }
}

class _Macro {
  final String title;
  final String value;
  final String desc;
  final double progress;
  final IconData icon;
  final Color color;
  final String badge;

  const _Macro({
    required this.title,
    required this.value,
    required this.desc,
    required this.progress,
    required this.icon,
    required this.color,
    required this.badge,
  });
}

const List<_Macro> _macros = [
  _Macro(
    title: 'Protein Hewani & Nabati',
    value: '25g · Target 25g (96%)',
    desc: 'Kunci pembentukan otot & percepatan linear growth',
    progress: 0.96,
    icon: Icons.egg_alt,
    color: Color(0xFF16A34A),
    badge: 'Optimal',
  ),
  _Macro(
    title: 'Energi & Karbohidrat',
    value: '890 / 1.100 kkal (81%)',
    desc: 'Sisa 210 kkal untuk menu makan malam',
    progress: 0.81,
    icon: Icons.local_fire_department,
    color: Color(0xFFEA580C),
    badge: 'Mendekati',
  ),
  _Macro(
    title: 'Lemak Sehat (Omega 3 & 6)',
    value: '30g (93%)',
    desc: 'Dukung mielinisasi otak balita',
    progress: 0.93,
    icon: Icons.water_drop,
    color: Color(0xFF0D9488),
    badge: 'Sangat Baik',
  ),
];

class _MacroCard extends StatelessWidget {
  final _Macro macro;

  const _MacroCard({required this.macro});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: macro.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(macro.icon, size: 21, color: macro.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      macro.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      macro.value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: macro.color,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(macro.badge),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: macro.progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFEFEFEF),
              valueColor: AlwaysStoppedAnimation(macro.color),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              macro.desc,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _Micro {
  final String name;
  final String pct;
  final String desc;
  final double progress;
  final Color color;

  const _Micro({
    required this.name,
    required this.pct,
    required this.desc,
    required this.progress,
    required this.color,
  });
}

const List<_Micro> _micros = [
  _Micro(
    name: 'Zat Besi (Fe)',
    pct: '82%',
    desc: 'Cegah anemia & dorong fokus',
    progress: 0.82,
    color: Color(0xFF16A34A),
  ),
  _Micro(
    name: 'Zinc (Seng)',
    pct: '90%',
    desc: 'Pertumbuhan sel & imunitas',
    progress: 0.90,
    color: Color(0xFF16A34A),
  ),
  _Micro(
    name: 'Kalsium',
    pct: '75%',
    desc: 'Tambah kebutuhan susu & keju',
    progress: 0.75,
    color: Color(0xFFEA580C),
  ),
  _Micro(
    name: 'Vitamin A & D',
    pct: '88%',
    desc: 'Kesehatan epitel mata & tulang',
    progress: 0.88,
    color: Color(0xFF16A34A),
  ),
  _Micro(
    name: 'DHA (Asam Lemak E)',
    pct: '95%',
    desc: 'Tercukupi dari ikan kembung & telur',
    progress: 0.95,
    color: Color(0xFF16A34A),
  ),
];

class _MicroSection extends StatelessWidget {
  const _MicroSection();

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label segera hadir'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Mikronutrien Kunci'),
        const _SectionSub('Proteksi Khusus Anti-Stunting'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _pill(context, 'Perkembangan Kognitif', active: true),
              const SizedBox(width: 8),
              _pill(context, 'Detail', active: false),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: Column(
            children: [
              for (final micro in _micros) _MicroRow(micro: micro),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(BuildContext context, String label, {required bool active}) {
    return GestureDetector(
      onTap: () {
        if (!active) _comingSoon(context, label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDark : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _MicroRow extends StatelessWidget {
  final _Micro micro;

  const _MicroRow({required this.micro});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  micro.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Text(
                micro.pct,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: micro.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: micro.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFEFEFEF),
              valueColor: AlwaysStoppedAnimation(micro.color),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  micro.desc,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meal {
  final String type;
  final String time;
  final String kcal;
  final String name;
  final String desc;
  final IconData icon;
  final Color color;
  final bool isPlan;

  const _Meal({
    required this.type,
    required this.time,
    required this.kcal,
    required this.name,
    required this.desc,
    required this.icon,
    required this.color,
    this.isPlan = false,
  });
}

const List<_Meal> _meals = [
  _Meal(
    type: 'MAKAN PAGI',
    time: '07:30',
    kcal: '320 kkal',
    name: 'Bubur Hati Ayam Bayam',
    desc: 'Zat besi heme, vitamin B, dan folat',
    icon: Icons.wb_sunny,
    color: Color(0xFFEA580C),
  ),
  _Meal(
    type: 'MAKAN SIANG',
    time: '12:15',
    kcal: '340 kkal',
    name: 'Nasi Tim Ikan Kembung Telur',
    desc: 'Omega tinggi, protein untuk linear growth',
    icon: Icons.restaurant,
    color: Color(0xFFD97706),
  ),
  _Meal(
    type: 'CAMILAN SORE',
    time: '15:45',
    kcal: '140 kkal',
    name: 'Puree Alpukat Pisang',
    desc: 'Lemak nabati sehat, kalium alami',
    icon: Icons.icecream,
    color: Color(0xFF0D9488),
  ),
  _Meal(
    type: 'MAKAN MALAM',
    time: '18:30',
    kcal: 'Est. 250 kkal',
    name: 'Sup Daging Sapi & Sayuran Labu',
    desc: 'Ditambah keju parut melengkapi kalsium harian',
    icon: Icons.bedtime,
    color: Color(0xFF4F46E5),
    isPlan: true,
  ),
];

class _MealTile extends StatelessWidget {
  final _Meal meal;

  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: meal.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  meal.time,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: meal.color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meal.kcal,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 44,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(meal.icon, size: 15, color: meal.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meal.isPlan ? '${meal.type} (RENCANA)' : meal.type,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: meal.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meal.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meal.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unduh Laporan Nutrisi',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Format PDF resmi untuk konsultasi dengan Posyandu/Dokter',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ekspor laporan PDF segera hadir'),
                  backgroundColor: AppColors.primaryMedium,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Ekspor',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}