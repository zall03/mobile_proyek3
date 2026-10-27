import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../recipe/domain/entities/recipe.dart';
import '../../../recipe/domain/utils/parse_steps.dart';
import '../../domain/entities/cooking_log.dart';
import '../pages/cooking_history_page.dart';

/// Ringkasan setelah sesi masak selesai.
///
/// Data berasal dari response server: bahan terpotong, sisa stok,
/// dan total gizi hasil takaran resep.
class CookSummaryView extends StatefulWidget {
  final Recipe recipe;
  final int servings;
  final CookingLog log;
  final int minutesSpent;

  const CookSummaryView({
    super.key,
    required this.recipe,
    required this.servings,
    required this.log,
    required this.minutesSpent,
  });

  @override
  State<CookSummaryView> createState() => _CookSummaryViewState();
}

class _CookSummaryViewState extends State<CookSummaryView> {
  bool _stepsExpanded = false;

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CookingHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = widget.log.nutrition;
    final steps = parseRecipeSteps(widget.recipe.instructions);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgGradientStart,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroBand(
              recipeName: widget.recipe.name,
              servings: widget.servings,
              minutesSpent: widget.minutesSpent,
              onClose: _goHome,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nutrition != null) ...[
                    _SectionHeader(
                      title: 'Kandungan Gizi',
                      subtitle: 'Takaran untuk ${widget.servings} porsi',
                    ),
                    const SizedBox(height: 10),
                    _NutritionCard(
                      summary: nutrition,
                      servings: widget.servings,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.log.touchedStock) ...[
                    const _SectionHeader(
                      title: 'Stok Terpakai',
                      subtitle: 'Bahan dipotong otomatis dari kulkas',
                    ),
                    const SizedBox(height: 10),
                    _CardContainer(child: _DeductionLedger(log: widget.log)),
                    const SizedBox(height: 24),
                  ],
                  if (widget.log.skipped.isNotEmpty) ...[
                    const _SectionHeader(
                      title: 'Bahan Tidak Dipotong',
                      subtitle: 'Tidak ditemukan pada daftar stok',
                    ),
                    const SizedBox(height: 10),
                    _CardContainer(
                      child: _SkippedList(skipped: widget.log.skipped),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (steps.isNotEmpty) ...[
                    _StepsAccordion(
                      steps: steps,
                      isExpanded: _stepsExpanded,
                      onToggle: () =>
                          setState(() => _stepsExpanded = !_stepsExpanded),
                    ),
                    const SizedBox(height: 28),
                  ],
                  _ActionButtons(onHome: _goHome, onHistory: _openHistory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBand extends StatelessWidget {
  final String recipeName;
  final int servings;
  final int minutesSpent;
  final VoidCallback onClose;

  const _HeroBand({
    required this.recipeName,
    required this.servings,
    required this.minutesSpent,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Selesai Memasak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Tutup dan kembali ke beranda',
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            recipeName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaBadge(
                icon: Icons.restaurant_menu,
                label: '$servings porsi',
              ),
              if (minutesSpent > 0)
                _MetaBadge(
                  icon: Icons.timer_outlined,
                  label: '$minutesSpent menit',
                )
              else
                const _MetaBadge(
                  icon: Icons.check,
                  label: 'Selesai dicatat',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionSummary summary;
  final int servings;

  const _NutritionCard({required this.summary, required this.servings});

  @override
  Widget build(BuildContext context) {
    final total = summary.total;
    final perServing = summary.perServing;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Energi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _fmt(total.calories),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: ' kkal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrangeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '≈ ${_fmt(perServing.calories)} kkal / porsi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrangeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.hairline),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _MacroColumn(
                    label: 'Protein',
                    total: total.proteinG,
                    perServing: perServing.proteinG,
                    unit: 'g',
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: AppColors.hairline,
                ),
                Expanded(
                  child: _MacroColumn(
                    label: 'Lemak',
                    total: total.fatG,
                    perServing: perServing.fatG,
                    unit: 'g',
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: AppColors.hairline,
                ),
                Expanded(
                  child: _MacroColumn(
                    label: 'Karbohidrat',
                    total: total.carbsG,
                    perServing: perServing.carbsG,
                    unit: 'g',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vitamin & Mineral Penting',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MicroRow(
                        label: 'Zat Besi',
                        value: total.ironMg,
                        unit: 'mg',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _MicroRow(
                        label: 'Zinc',
                        value: total.zincMg,
                        unit: 'mg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MicroRow(
                        label: 'Vitamin A',
                        value: total.vitaminAMcg,
                        unit: 'mcg',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _MicroRow(
                        label: 'Vitamin C',
                        value: total.vitaminCMg,
                        unit: 'mg',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (summary.excluded.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                'Belum dihitung ke total gizi: '
                '${summary.excluded.map((e) => '${e.ingredient} (${e.reason})').join(', ')}.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF78350F),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v == 0) return '0';
    var s = v.abs() >= 100
        ? v.toStringAsFixed(0)
        : v.abs() >= 10
            ? v.toStringAsFixed(1)
            : v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }
}

class _MacroColumn extends StatelessWidget {
  final String label;
  final double total;
  final double perServing;
  final String unit;

  const _MacroColumn({
    required this.label,
    required this.total,
    required this.perServing,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_NutritionCard._fmt(total)} $unit',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '≈ ${_NutritionCard._fmt(perServing)}$unit / porsi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _MicroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _MicroRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.hairline,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
          Text(
            '${_NutritionCard._fmt(value)} $unit',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeductionLedger extends StatelessWidget {
  final CookingLog log;

  const _DeductionLedger({required this.log});

  @override
  Widget build(BuildContext context) {
    final rows = <({String name, String used, String remaining, bool emptied})>[
      for (final change in log.deducted)
        (
          name: change.ingredient,
          used: '-${_num(change.used)} ${change.unit}',
          remaining: 'Sisa ${_num(change.to)} ${change.unit}',
          emptied: false,
        ),
      for (final change in log.removed)
        (
          name: change.ingredient,
          used: 'Habis terpakai',
          remaining: 'Stok sekarang kosong',
          emptied: true,
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rows[i].name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rows[i].remaining,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rows[i].emptied
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rows[i].used,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: rows[i].emptied
                          ? AppColors.textGrey
                          : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i < rows.length - 1)
            const Divider(height: 1, thickness: 1, color: AppColors.hairline),
        ],
      ],
    );
  }

  static String _num(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}

class _SkippedList extends StatelessWidget {
  final List<SkippedIngredient> skipped;

  const _SkippedList({required this.skipped});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < skipped.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${skipped[i].ingredient} (${skipped[i].reason})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i < skipped.length - 1)
            const Divider(height: 1, thickness: 1, color: AppColors.hairline),
        ],
      ],
    );
  }
}

class _StepsAccordion extends StatelessWidget {
  final List<String> steps;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _StepsAccordion({
    required this.steps,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan Langkah Memasak',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${steps.length} langkah telah diselesaikan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textGrey,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  for (final entry in steps.asMap().entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onHistory;

  const _ActionButtons({required this.onHome, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Kembali ke Beranda',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onHistory,
            icon: const Icon(Icons.history, size: 18),
            label: Text(
              'Lihat Riwayat Masak',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(
                color: AppColors.primaryDark,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
