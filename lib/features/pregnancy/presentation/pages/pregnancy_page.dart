import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/pregnancy.dart';
import '../cubit/pregnancy_cubit.dart';
import '../cubit/pregnancy_state.dart';
import 'pregnancy_form_page.dart';

/// Profil kehamilan: sumber data 270 hari pertama dari 1000 HPK.
///
/// Semua angka dihitung dari HPHT; HPL memakai rumus Naegele (HPHT + 280 hari).
/// Dial: ENERGY 1 / RHYTHM 1 / MOTION 1 (satu kartu status sebagai fokus,
/// sisanya daftar fakta dan aksi; hijau sebagai warna inti, aksen oranye hanya
/// pada angka hari tersisa).
class PregnancyPage extends StatelessWidget {
  const PregnancyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PregnancyCubit>()..load(),
      child: const _PregnancyView(),
    );
  }
}

class _PregnancyView extends StatelessWidget {
  const _PregnancyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: Text(
          'Profil Kehamilan',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<PregnancyCubit, PregnancyState>(
        builder: (context, state) {
          if (state is PregnancyInitial || state is PregnancyLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryDark),
                  const SizedBox(height: 14),
                  Text(
                    'Memuat data kehamilan...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PregnancyFailure) {
            return _Message(
              icon: Icons.cloud_off,
              title: 'Gagal memuat data',
              body: state.message,
              actionLabel: 'Coba lagi',
              onAction: () => context.read<PregnancyCubit>().load(),
            );
          }

          final pregnancy = state is PregnancyLoaded
              ? state.pregnancy
              : (state as PregnancySaving).pregnancy;

          if (pregnancy == null) {
            return _Message(
              icon: Icons.pregnant_woman,
              title: 'Belum ada data kehamilan',
              body: 'Isi tanggal HPHT (hari pertama haid terakhir) supaya usia kehamilan, trimester, dan perkiraan hari lahir terhitung otomatis.',
              actionLabel: 'Tambah data kehamilan',
              onAction: () => _openForm(context),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(pregnancy: pregnancy),
                const SizedBox(height: 16),
                _FactsCard(pregnancy: pregnancy),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _openForm(context, pregnancy),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      'Perbarui data',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelivered(context, pregnancy),
                    icon: const Icon(Icons.child_friendly, size: 18),
                    label: Text(
                      'Tandai sudah melahirkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _confirmDelete(context, pregnancy),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(
                      'Hapus data',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, [Pregnancy? pregnancy]) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PregnancyCubit>(),
          child: PregnancyFormPage(pregnancy: pregnancy),
        ),
      ),
    );
  }

  Future<void> _confirmDelivered(
    BuildContext context,
    Pregnancy pregnancy,
  ) async {
    final cubit = context.read<PregnancyCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Tandai sudah melahirkan?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Status kehamilan ditutup dan tersimpan sebagai riwayat. Profil anak bisa ditambahkan dari halaman profil.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya, sudah lahir',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final error = await cubit.markAsDelivered(pregnancy.id);
    if (error != null && context.mounted) _snack(context, error);
  }

  Future<void> _confirmDelete(BuildContext context, Pregnancy pregnancy) async {
    final cubit = context.read<PregnancyCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus data kehamilan?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Data kehamilan ini dihapus permanen dan tidak bisa dikembalikan.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final error = await cubit.remove(pregnancy.id);
    if (error != null && context.mounted) _snack(context, error);
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Pregnancy pregnancy;

  const _StatusCard({required this.pregnancy});

  @override
  Widget build(BuildContext context) {
    final progress = pregnancy.progressPercent / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pregnant_woman,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregnancy.motherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Minggu ${pregnancy.ageInWeeks} · Trimester ${pregnancy.trimester}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Hari ${pregnancy.ageInDays} dari ${Pregnancy.gestationDays}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${pregnancy.progressPercent.toStringAsFixed(0)}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FactsCard extends StatelessWidget {
  final Pregnancy pregnancy;

  const _FactsCard({required this.pregnancy});

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
      child: Column(
        children: [
          _Fact(
            icon: Icons.event_available,
            label: 'Perkiraan hari lahir',
            value: DateFormat('d MMMM yyyy', 'id').format(pregnancy.dueDate),
          ),
          const Divider(height: 24, color: AppColors.hairline),
          _Fact(
            icon: Icons.hourglass_bottom,
            label: 'Sisa waktu',
            value: '${pregnancy.daysRemaining} hari',
            highlighted: true,
          ),
          const Divider(height: 24, color: AppColors.hairline),
          _Fact(
            icon: Icons.calendar_today,
            label: 'HPHT',
            value: DateFormat('d MMMM yyyy', 'id').format(pregnancy.hphtDate),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  /// Aksen oranye dipakai di satu titik saja: hitungan hari tersisa,
  /// angka yang berubah tiap hari dan paling dicari bunda.
  final bool highlighted;

  const _Fact({
    required this.icon,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: highlighted ? AppColors.accentOrangeText : AppColors.ink,
      ),
    );

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.bgGradientStart,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: AppColors.primaryMedium),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 3),
              if (highlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrangeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: valueText,
                )
              else
                valueText,
            ],
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.bgGradientStart,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.6,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
