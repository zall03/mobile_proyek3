import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ingredient_image.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_audience.dart';
import '../../domain/utils/parse_steps.dart';

/// Satu-satunya tempat data resep dirender.
///
/// Dipakai bersama oleh halaman resep tersimpan dan halaman hasil AI supaya
/// keduanya tidak berbeda secara visual.
class RecipeBody extends StatelessWidget {
  final Recipe recipe;
  final RecipeAudience? audience;
  final ValueChanged<int>? onCook;

  const RecipeBody({
    super.key,
    required this.recipe,
    this.audience,
    this.onCook,
  });

  List<String> get _steps => parseRecipeSteps(recipe.instructions);

  @override
  Widget build(BuildContext context) {
    final base = recipe.servings < 1 ? 1 : recipe.servings;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _TitleBlock(recipe: recipe),
        const SizedBox(height: 14),
        _MetaRow(
          cookTimeMinutes: recipe.cookTimeMinutes,
          isAi: recipe.source == 'ai_generated',
          audienceLabel: audience?.label,
        ),
        const SizedBox(height: 18),
        if (recipe.description.isNotEmpty) ...[
          Text(
            recipe.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 26),
        ],
        if (recipe.ingredients.isNotEmpty) ...[
          _SectionLabel(
            'Bahan',
            trailing: '${recipe.ingredients.length} bahan',
          ),
          const SizedBox(height: 14),
          _IngredientLedger(
            ingredients: recipe.ingredients,
            factor: 1.0,
          ),
          const SizedBox(height: 30),
        ],
        if (_steps.isNotEmpty) ...[
          _SectionLabel('Cara memasak', trailing: '${_steps.length} langkah'),
          const SizedBox(height: 16),
          ..._steps.asMap().entries.map(
            (entry) => _StepRow(
              number: entry.key + 1,
              text: entry.value,
              isLast: entry.key == _steps.length - 1,
            ),
          ),
        ],
        if (recipe.ingredients.isEmpty && _steps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'Data resep ini belum lengkap. Coba generate ulang dari bahan yang kamu punya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ),
        if (onCook != null) ...[
          const SizedBox(height: 28),
          _CookButton(onPressed: () => onCook!(base)),
          const SizedBox(height: 10),
          Text(
            'Mode masak memandu langkah satu per satu dan memotong stok setelah selesai.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final Recipe recipe;

  const _TitleBlock({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Text(
      recipe.name,
      style: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryDark,
        height: 1.2,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final int cookTimeMinutes;
  final bool isAi;
  final String? audienceLabel;

  const _MetaRow({
    required this.cookTimeMinutes,
    required this.isAi,
    this.audienceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(
          icon: Icons.timer_outlined,
          label: '$cookTimeMinutes menit',
          foreground: const Color(0xFF9A4B00),
          background: const Color(0xFFFFF3E0),
        ),
        if (audienceLabel != null && audienceLabel!.isNotEmpty) ...[
          _MetaChip(
            icon: Icons.people_outline,
            label: audienceLabel!,
            foreground: const Color(0xFF1565C0),
            background: const Color(0xFFE3F2FD),
          ),
        ],
        if (isAi) ...[
          _MetaChip(
            icon: Icons.auto_awesome,
            label: 'Racikan AI',
            foreground: AppColors.primaryDark,
            background: const Color(0xFFE8F5E9),
          ),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;

  const _SectionLabel(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }
}



class _IngredientLedger extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  final double factor;

  const _IngredientLedger({required this.ingredients, required this.factor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.asMap().entries.map((entry) {
        final ing = entry.value;
        final isLast = entry.key == ingredients.length - 1;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  IngredientThumb(
                    imageUrl: ing.imageUrl,
                    name: ing.ingredientName,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ing.ingredientName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        if (ing.inStock)
                          Text(
                            'Ada di kulkasmu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.primaryMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatQuantity(ing.quantityNeeded * factor, ing.unit),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ],
        );
      }).toList(),
    );
  }
}

/// Bulatkan takaran agar tetap masuk akal di dapur.
///
/// Satuan hitung (butir, buah, siung) dibulatkan ke kelipatan setengah;
/// satuan timbang/takar memakai satu angka desimal.
String formatQuantity(double value, String unit) {
  final countable = const [
    'butir',
    'buah',
    'biji',
    'siung',
    'iris',
    'batang',
    'potong',
  ].contains(unit.toLowerCase());

  double rounded;
  if (countable) {
    rounded = (value * 2).round() / 2;
    if (rounded < 0.5) rounded = 0.5;
  } else {
    rounded = (value * 10).round() / 10;
  }

  final text = rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toStringAsFixed(1);

  return unit.isEmpty ? text : '$text $unit';
}

class IngredientThumb extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const IngredientThumb({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return IngredientImage(
      imageUrl: imageUrl,
      name: name,
      size: 40,
      borderRadius: 8,
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const _StepRow({
    required this.number,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CookButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CookButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mulai Memasak',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
