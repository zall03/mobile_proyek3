import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/hpk.dart';
import '../../../../injection_container.dart';
import '../../../pregnancy/domain/entities/pregnancy.dart';
import '../../../pregnancy/presentation/pages/birth_form_page.dart';
import '../../../pregnancy/presentation/pages/pregnancy_page.dart';
import '../../domain/entities/child.dart';
import '../cubit/hpk_cubit.dart';
import '../cubit/hpk_state.dart';
import '../widgets/child_profile_form.dart';
import 'child_detail_page.dart';

// Design Read: 1000 HPK dashboard for Indonesian mothers, forest-green
// editorial language, dial ENERGY 1 / RHYTHM 2 / MOTION 1.
// Motif: one progress rail per person, measured in days of the first 1000.

class HpkHubPage extends StatelessWidget {
  const HpkHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HpkCubit>()..load(),
      child: const _HpkView(),
    );
  }
}

class _HpkView extends StatelessWidget {
  const _HpkView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDeep),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1000 HPK',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.primaryDeep,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1.1,
              ),
            ),
            Text(
              'Hari pertama kehidupan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<HpkCubit, HpkState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loaded: (data) => RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<HpkCubit>().load(),
              child: _Body(data: data),
            ),
            failure: (message) => _ErrorView(
              message: message,
              onRetry: () => context.read<HpkCubit>().load(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddChildDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showAddChildDialog(BuildContext context) async {
  final cubit = context.read<HpkCubit>();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => ChildProfileForm(
      onSubmit:
          ({
            required name,
            required gender,
            required birthDate,
            hpht,
            birthWeightKg,
            birthLengthCm,
            birthHeadCircumferenceCm,
          }) async {
            final error = await cubit.createChild(
              name: name,
              gender: gender,
              birthDate: birthDate,
              hpht: hpht,
              birthWeightKg: birthWeightKg,
              birthLengthCm: birthLengthCm,
              birthHeadCircumferenceCm: birthHeadCircumferenceCm,
            );
            if (!dialogContext.mounted) return;
            if (error == null) {
              Navigator.pop(dialogContext);
            } else {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text(
                    error,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
    ),
  );
}

class _Body extends StatelessWidget {
  final HpkLoadedState data;

  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    final activeChildren = data.children
        .where((child) => !child.isHpkComplete)
        .toList();
    final completedChildren = data.children
        .where((child) => child.isHpkComplete)
        .toList();
    final pastPregnancies = data.history
        .where((pregnancy) => !pregnancy.isActive)
        .toList();
    final hasHistory =
        completedChildren.isNotEmpty || pastPregnancies.isNotEmpty;

    if (data.isEmpty) {
      return _EmptyState(
        onAddChild: () => _showAddChildDialog(context),
        onStartPregnancy: () =>
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PregnancyPage()),
            ).then((_) {
              if (context.mounted) context.read<HpkCubit>().load();
            }),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (data.pregnancy != null)
          _PregnancyCard(
            pregnancy: data.pregnancy!,
            onBirth: () => _openBirth(context, data.pregnancy!),
            onManage: () => _openPregnancy(context),
          ),
        if (data.pregnancy == null)
          _StartPregnancyCard(onTap: () => _openPregnancy(context)),
        if (activeChildren.isNotEmpty) ...[
          const SizedBox(height: 22),
          _SectionTitle(
            title: 'Anak',
            trailing: '${activeChildren.length} dipantau',
          ),
          const SizedBox(height: 10),
          for (final child in activeChildren) ...[
            _ChildCard(
              child: child,
              onTap: () => _openChild(context, child),
              onEdit: () => _editChild(context, child),
              onDelete: () => _deleteChild(context, child),
            ),
            const SizedBox(height: 10),
          ],
        ],
        if (hasHistory) ...[
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Riwayat 1000 HPK'),
          const SizedBox(height: 10),
          for (final pregnancy in pastPregnancies)
            _HistoryRow(
              icon: Icons.pregnant_woman,
              title: pregnancy.motherName,
              subtitle:
                  'Kehamilan selesai · '
                  '${pregnancy.isDelivered ? "sudah melahirkan" : "diarsipkan"}',
            ),
          for (final child in completedChildren)
            _HistoryRow(
              icon: child.gender == 'male' ? Icons.boy : Icons.girl,
              title: child.name,
              subtitle:
                  'Melewati 1000 hari pada '
                  '${DateFormat('d MMM yyyy', 'id').format(hpkEndDate(child.effectiveHpht))}',
            ),
        ],
      ],
    );
  }

  Future<void> _openChild(BuildContext context, Child child) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildDetailPage(child: child)),
    );
    if (context.mounted) context.read<HpkCubit>().load();
  }

  Future<void> _openBirth(BuildContext context, Pregnancy pregnancy) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BirthFormPage(pregnancy: pregnancy)),
    );
    if (saved == true && context.mounted) {
      context.read<HpkCubit>().load();
    }
  }

  Future<void> _openPregnancy(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PregnancyPage()),
    );
    if (context.mounted) context.read<HpkCubit>().load();
  }

  Future<void> _editChild(BuildContext context, Child child) async {
    final cubit = context.read<HpkCubit>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ChildProfileForm(
        initialChild: child,
        onSubmit:
            ({
              required name,
              required gender,
              required birthDate,
              hpht,
              birthWeightKg,
              birthLengthCm,
              birthHeadCircumferenceCm,
            }) async {
              final error = await cubit.updateChild(
                id: child.id,
                name: name,
                gender: gender,
                birthDate: birthDate,
                hpht: hpht,
                birthWeightKg: birthWeightKg,
                birthLengthCm: birthLengthCm,
                birthHeadCircumferenceCm: birthHeadCircumferenceCm,
              );
              if (!dialogContext.mounted) return;
              if (error == null) {
                Navigator.pop(dialogContext);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      error,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
      ),
    );
  }

  Future<void> _deleteChild(BuildContext context, Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus profil?'),
        content: Text(
          'Profil ${child.name} beserta semua catatan pengukurannya akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<HpkCubit>().deleteChild(child.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PregnancyCard extends StatelessWidget {
  final Pregnancy pregnancy;
  final VoidCallback onBirth;
  final VoidCallback onManage;

  const _PregnancyCard({
    required this.pregnancy,
    required this.onBirth,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final day = pregnancy.hpkDay;
    final progress = pregnancy.hpkProgress;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDeep, AppColors.primary],
        ),
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Stack(
        children: [
          const Positioned(
            right: -16,
            top: -18,
            child: Icon(Icons.eco_rounded, size: 110, color: Colors.white10),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kehamilan aktif',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pregnancy.motherName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Minggu ke-${pregnancy.ageInWeeks} · trimester ${pregnancy.trimester}'
                ' · HPL ${DateFormat('d MMM yyyy', 'id').format(pregnancy.dueDate)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hari $day',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 3),
                    child: Text(
                      'dari 1000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFF79500)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onBirth,
                      icon: const Icon(Icons.child_friendly, size: 18),
                      label: Text(
                        'Catat kelahiran',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDeep,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    width: 44,
                    child: IconButton(
                      onPressed: onManage,
                      tooltip: 'Kelola kehamilan',
                      icon: const Icon(Icons.tune, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartPregnancyCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StartPregnancyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentOrangeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pregnant_woman,
              color: AppColors.accentOrangeText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada kehamilan aktif',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mulai hitung 1000 HPK dari HPHT.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              'Mulai',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = child.hpkProgress;
    final day = child.hpkDay;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
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
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      child.gender == 'male' ? Icons.boy : Icons.girl,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${child.ageInMonths} bulan'
                          '${child.isEstimatedHpht ? " · HPHT perkiraan" : ""}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Opsi profil',
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Hari $day dari 1000',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.hairline,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HistoryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddChild;
  final VoidCallback onStartPregnancy;

  const _EmptyState({required this.onAddChild, required this.onStartPregnancy});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 96),
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.child_care,
              size: 44,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Belum ada yang dipantau',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Mulai dari kehamilan dengan HPHT, atau tambahkan profil anak '
          'yang sudah lahir.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: onStartPregnancy,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Mulai profil kehamilan',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: onAddChild,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDeep,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Tambah profil anak',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 44),
            const SizedBox(height: 10),
            Text(
              'Gagal memuat data 1000 HPK',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
