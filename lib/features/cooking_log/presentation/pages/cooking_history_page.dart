import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../recipe/presentation/pages/recipe_detail_page.dart';
import '../../domain/entities/cooking_log.dart';
import '../cubit/cooking_history_cubit.dart';
import '../cubit/cooking_history_state.dart';

/// Riwayat sesi masak 30 hari terakhir.
class CookingHistoryPage extends StatelessWidget {
  const CookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Riwayat Memasak',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocProvider(
        create: (_) => sl<CookingHistoryCubit>()..load(),
        child: BlocBuilder<CookingHistoryCubit, CookingHistoryState>(
          builder: (context, state) {
            if (state is CookingHistoryLoading ||
                state is CookingHistoryInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              );
            }

            if (state is CookingHistoryFailure) {
              return _Empty(
                icon: Icons.cloud_off,
                title: 'Gagal memuat riwayat',
                message: state.message,
                onRetry: () => context.read<CookingHistoryCubit>().load(),
              );
            }

            final logs = (state as CookingHistoryLoaded).logs;

            if (logs.isEmpty) {
              return const _Empty(
                icon: Icons.history,
                title: 'Belum ada riwayat',
                message: 'Sesi masak yang kamu selesaikan akan tercatat di sini beserta bahan yang terpakai.',
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () => context.read<CookingHistoryCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
                itemBuilder: (context, index) => _HistoryRow(
                  log: logs[index],
                  recipeName: logs[index].recipeName ?? 'Resep tidak tersedia',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryRow extends StatefulWidget {
  final CookingLog log;
  final String recipeName;

  const _HistoryRow({required this.log, required this.recipeName});

  @override
  State<_HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<_HistoryRow> {
  bool _expanded = false;

  void _openRecipeDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(recipeId: widget.log.recipeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final recipeName = widget.recipeName;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 18,
                    color: AppColors.primaryMedium,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_when(log.cookedAt)} · ${log.servings} porsi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (log.durationMinutes != null)
                      Text(
                        '${log.durationMinutes} mnt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _HistoryDetail(
            log: log,
            onOpenRecipe: _openRecipeDetail,
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  static String _when(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final difference = today.difference(day).inDays;

    if (difference == 0) return 'Hari ini ${DateFormat.Hm().format(time)}';
    if (difference == 1) return 'Kemarin ${DateFormat.Hm().format(time)}';
    if (difference < 7) {
      return '${DateFormat.EEEE('id').format(time)} ${DateFormat.Hm().format(time)}';
    }

    return DateFormat('d MMM, HH:mm', 'id').format(time);
  }
}

class _HistoryDetail extends StatelessWidget {
  final CookingLog log;
  final VoidCallback onOpenRecipe;

  const _HistoryDetail({required this.log, required this.onOpenRecipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 52, right: 0, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.deducted.isNotEmpty) ...[
            Text(
              'Bahan yang terpakai',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            for (final item in log.deducted)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.primaryMedium,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.ingredient,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Text(
                      '-${_fmt(item.used)} ${item.unit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
          ],
          if (log.nutrition != null) ...[
            Text(
              'Total gizi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _NutChip(
                  label:
                      '${log.nutrition!.total.calories.toStringAsFixed(0)} kkal',
                ),
                _NutChip(
                  label:
                      'P ${log.nutrition!.total.proteinG.toStringAsFixed(1)} g',
                ),
                _NutChip(
                  label: 'L ${log.nutrition!.total.fatG.toStringAsFixed(1)} g',
                ),
                _NutChip(
                  label:
                      'K ${log.nutrition!.total.carbsG.toStringAsFixed(1)} g',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: onOpenRecipe,
              icon: const Icon(Icons.menu_book_outlined, size: 16),
              label: Text(
                'Lihat resep & langkah lengkap',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.primaryDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _NutChip extends StatelessWidget {
  final String label;
  const _NutChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _Empty({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: AppColors.textGrey),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textGrey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.primaryDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Coba lagi',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
