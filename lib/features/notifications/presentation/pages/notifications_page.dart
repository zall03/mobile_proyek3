import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ingredient_image.dart';
import '../../../../injection_container.dart';
import '../../../child/domain/entities/child.dart';
import '../../../child/presentation/pages/child_detail_page.dart';
import '../../../recipe/presentation/pages/ai_recipe_result_page.dart';
import '../../../stock/domain/entities/stock.dart';
import '../../../stock/presentation/pages/stock_page.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../../domain/entities/notification_overview.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.bgGradientStart,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifikasi',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: BlocConsumer<NotificationsCubit, NotificationsState>(
          listener: (context, state) {},
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              ),
              loaded: (overview) =>
                  _NotificationList(overview: overview, context: context),
              failure: (message) => _FailureView(
                message: message,
                onRetry: () => context.read<NotificationsCubit>().load(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final NotificationOverview overview;
  final BuildContext context;

  const _NotificationList({required this.overview, required this.context});

  Future<void> _openAi(BuildContext ctx, Stock item) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) =>
            AiRecipeResultPage(ingredientIds: [item.ingredient.id]),
      ),
    );
    if (ctx.mounted) ctx.read<NotificationsCubit>().load();
  }

  Future<void> _openStock(BuildContext ctx) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const StockPage()),
    );
    if (ctx.mounted) ctx.read<NotificationsCubit>().load();
  }

  Future<void> _openChild(BuildContext ctx, MeasurementReminder reminder) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => ChildDetailPage(
          child: Child(
            id: reminder.childId,
            name: reminder.name,
            gender: reminder.gender,
            birthDate: reminder.birthDate,
          ),
        ),
      ),
    );
    if (ctx.mounted) ctx.read<NotificationsCubit>().load();
  }

  String _qty(Stock s) =>
      s.quantity.toStringAsFixed(s.quantity % 1 == 0 ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    if (overview.isEmpty) return const _EmptyView();
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().load(),
      color: AppColors.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (overview.expiring.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFEF3C7),
              title: 'Perlu Diolah',
              count: '${overview.expiring.length} bahan',
              countColor: const Color(0xFFB45309),
              countBg: const Color(0xFFFFF3CD),
            ),
            const SizedBox(height: 10),
            ...overview.expiring.map(
              (s) => _ExpiringTile(
                item: s,
                subtitle: '${_qty(s)} ${s.unit}',
                onCook: () => _openAi(context, s),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (overview.lowStock.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF1D4ED8),
              iconBg: const Color(0xFFE0E7FF),
              title: 'Bahan Menipis',
              count: '${overview.lowStock.length} bahan',
              countColor: const Color(0xFF1D4ED8),
              countBg: const Color(0xFFE0E7FF),
            ),
            const SizedBox(height: 10),
            ...overview.lowStock.map(
              (s) => _LowStockTile(
                item: s,
                subtitle: 'Sisa ${_qty(s)} ${s.unit}',
                onAdd: () => _openStock(context),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (overview.measurementDue.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.straighten,
              iconColor: const Color(0xFF15803D),
              iconBg: const Color(0xFFDCFCE7),
              title: 'Jadwal Ukur Si Kecil',
              count: '${overview.measurementDue.length} anak',
              countColor: const Color(0xFF15803D),
              countBg: const Color(0xFFDCFCE7),
            ),
            const SizedBox(height: 10),
            ...overview.measurementDue.map(
              (m) => _MeasureTile(
                reminder: m,
                onRecord: () => _openChild(context, m),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String count;
  final Color countColor;
  final Color countBg;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.count,
    required this.countColor,
    required this.countBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: countBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: countColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpiringTile extends StatelessWidget {
  final Stock item;
  final String subtitle;
  final VoidCallback onCook;

  const _ExpiringTile({
    required this.item,
    required this.subtitle,
    required this.onCook,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = item.status == StockStatus.expired;
    final statusColor = isExpired
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706);
    final statusText = isExpired
        ? 'Kedaluwarsa'
        : 'Sisa ${item.daysLeft ?? 0} hari lagi';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IngredientImage(
                imageUrl: item.ingredient.imageUrl,
                name: item.ingredient.name,
                size: 52,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ingredient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          isExpired
                              ? Icons.warning_amber_rounded
                              : Icons.schedule,
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            statusText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onCook,
              icon: const Icon(Icons.restaurant_rounded, size: 16),
              label: Text(
                'Olah Jadi Resep',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDCFCE7),
                foregroundColor: const Color(0xFF166534),
                padding: const EdgeInsets.symmetric(vertical: 11),
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
}

class _LowStockTile extends StatelessWidget {
  final Stock item;
  final String subtitle;
  final VoidCallback onAdd;

  const _LowStockTile({
    required this.item,
    required this.subtitle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDE9)),
      ),
      child: Row(
        children: [
          IngredientImage(
            imageUrl: item.ingredient.imageUrl,
            name: item.ingredient.name,
            size: 44,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ingredient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1B5E20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Tambah Stok',
              style: GoogleFonts.plusJakartaSans(
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

class _MeasureTile extends StatelessWidget {
  final MeasurementReminder reminder;
  final VoidCallback onRecord;

  const _MeasureTile({
    required this.reminder,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final last = reminder.lastMeasuredAt;
    final subtitle = last == null
        ? 'Belum pernah diukur'
        : 'Ukur terakhir ${reminder.daysSinceLast ?? 0} hari lalu'
              '${reminder.lastWeight != null ? ' • ${reminder.lastWeight!} kg' : ''}'
              '${reminder.lastHeight != null ? ' • ${reminder.lastHeight!} cm' : ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFDCFCE7),
                child: Text(
                  reminder.name.isNotEmpty
                      ? reminder.name[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF6B7280),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRecord,
              icon: const Icon(Icons.straighten, size: 16),
              label: Text(
                'Catat Pengukuran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
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
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Semua sudah terpantau',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada bahan mendekati kedaluwarsa, stok menipis, atau jadwal ukur Si Kecil.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat notifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}