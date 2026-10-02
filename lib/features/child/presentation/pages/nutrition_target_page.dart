import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/child.dart';

class NutritionTargetPage extends StatelessWidget {
  final Child child;

  const NutritionTargetPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final targets = _computeTargets(child);
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Target Gizi Harian',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChildHeader(child: child),
            const SizedBox(height: 16),
            Text(
              'Angka Kecukupan Gizi (AKG)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kebutuhan gizi harian berdasarkan usia. Rumus dari Kemenkes RI.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            _TargetGrid(targets: targets),
            const SizedBox(height: 24),
            _DailyNote(),
          ],
        ),
      ),
    );
  }

  NutritionTarget _computeTargets(Child child) {
    return nutritionTargetForAge(child.ageInMonths, child.gender);
  }
}

class _ChildHeader extends StatelessWidget {
  final Child child;

  const _ChildHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    final months = child.ageInMonths;
    final ageText = months < 24
        ? '$months bulan'
        : '${months ~/ 12} tahun ${months % 12} bulan';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              child.gender == 'male' ? Icons.boy : Icons.girl,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ageText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDB750),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Fase MPASI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetGrid extends StatelessWidget {
  final NutritionTarget targets;

  const _TargetGrid({required this.targets});

  @override
  Widget build(BuildContext context) {
    final items = [
      _TargetValue(label: 'Energi', value: targets.calories, unit: 'kkal', icon: Icons.local_fire_department, color: const Color(0xFFE65100)),
      _TargetValue(label: 'Protein', value: targets.proteinG, unit: 'g', icon: Icons.egg_alt, color: const Color(0xFF2E7D32)),
      _TargetValue(label: 'Lemak', value: targets.fatG, unit: 'g', icon: Icons.water_drop, color: const Color(0xFFF9A825)),
      _TargetValue(label: 'Karbohidrat', value: targets.carbsG, unit: 'g', icon: Icons.grain, color: const Color(0xFF6D4C41)),
      _TargetValue(label: 'Zat Besi', value: targets.ironMg, unit: 'mg', icon: Icons.healing, color: const Color(0xFFC62828)),
      _TargetValue(label: 'Zinc', value: targets.zincMg, unit: 'mg', icon: Icons.spa, color: const Color(0xFF00838F)),
      _TargetValue(label: 'Vitamin A', value: targets.vitaminAMcg, unit: 'mcg', icon: Icons.visibility, color: const Color(0xFF7B1FA2)),
      _TargetValue(label: 'Vitamin C', value: targets.vitaminCMg, unit: 'mg', icon: Icons.health_and_safety, color: const Color(0xFFEF6C00)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 16, color: item.color),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: item.value.round().toString(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF263238),
                      ),
                    ),
                    TextSpan(
                      text: ' ${item.unit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DailyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF9A825), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFF9A825), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gizi seimbang kunci cegah stunting: beragam menu, protein hewani setiap makan, kudapan bergizi, dan jadwal makan teratur.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF4E342E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetValue {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  const _TargetValue({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

class AkgCalculator {
  AkgCalculator._();

  static const _basisData = [
    _AkgBasis(6, 725, 20, 36, 82, 11, 3, 400, 40),
    _AkgBasis(12, 1125, 26, 44, 155, 7, 4, 400, 40),
    _AkgBasis(24, 1125, 26, 44, 155, 7, 4, 400, 40),
    _AkgBasis(36, 1250, 30, 47, 160, 8, 5, 450, 45),
    _AkgBasis(60, 1600, 40, 55, 220, 10, 9, 450, 45),
    _AkgBasis(84, 1850, 50, 65, 250, 13, 10, 500, 50),
  ];

  static NutritionTarget compute(int ageInMonths, String gender) {
    final years = ageInMonths / 12;
    for (var i = _basisData.length - 1; i >= 0; i--) {
      if (years >= _basisData[i].ageMonths / 12) {
        final b = _basisData[i];
        return NutritionTarget(
          id: 0,
          childId: 0,
          calories: b.calories,
          proteinG: b.proteinG,
          fatG: b.fatG,
          carbsG: b.carbsG,
          ironMg: b.ironMg,
          zincMg: b.zincMg,
          vitaminAMcg: b.vitaminAMcg,
          vitaminCMg: b.vitaminCMg,
        );
      }
    }
    final b = _basisData.first;
    return NutritionTarget(
      id: 0,
      childId: 0,
      calories: b.calories,
      proteinG: b.proteinG,
      fatG: b.fatG,
      carbsG: b.carbsG,
      ironMg: b.ironMg,
      zincMg: b.zincMg,
      vitaminAMcg: b.vitaminAMcg,
      vitaminCMg: b.vitaminCMg,
    );
  }
}

class _AkgBasis {
  final int ageMonths;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double ironMg;
  final double zincMg;
  final double vitaminAMcg;
  final double vitaminCMg;

  const _AkgBasis(
    this.ageMonths,
    this.calories,
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.ironMg,
    this.zincMg,
    this.vitaminAMcg,
    this.vitaminCMg,
  );
}

NutritionTarget nutritionTargetForAge(int ageInMonths, String gender) {
  return AkgCalculator.compute(ageInMonths, gender);
}