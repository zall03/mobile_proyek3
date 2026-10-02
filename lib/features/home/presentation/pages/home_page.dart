import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/ingredient_image.dart';
import '../../../../injection_container.dart';
import '../../../child/domain/entities/child.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../child/presentation/pages/child_list_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../recipe/presentation/pages/ai_recipe_result_page.dart';
import '../../../recipe/presentation/pages/recipe_list_page.dart';
import '../../../stock/domain/entities/stock.dart';
import '../../../stock/presentation/cubit/stock_cubit.dart';
import '../../../stock/presentation/cubit/stock_state.dart';
import '../../../stock/presentation/pages/stock_page.dart';
import '../../../stock/presentation/widgets/add_stock_sheet.dart';
import '../../../nutrition/presentation/pages/nutrition_page.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

// Design Read: maternal kitchen companion for Indonesian mothers
// Dial: ENERGY 2 / RHYTHM 2 / MOTION 1
// Palette: deep leaf green #1B5E20 primary, warm amber #FB8C00 accent, soft mint bg
// Type: Playfair Display for warm editorial greeting, Plus Jakarta Sans for body

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadDashboard(),
      child: _HomeContent(userName: userName),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final String userName;

  const _HomeContent({required this.userName});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _navIndex = 0);
      context.read<HomeCubit>().loadDashboard();
      return;
    }
    if (index == 2) {
      _showAiSheet();
      return;
    }
    Widget page;
    switch (index) {
      case 1:
        page = const StockPage();
        break;
      case 3:
        page = const NutritionPage();
        break;
      case 4:
        page = const ChildListPage();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) {
      if (!mounted) return;
      // refresh ringkasan setelah kembali dari Stok / Si Kecil
      context.read<HomeCubit>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F6),
          appBar: _buildAppBar(context, state),
          body: RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().loadDashboard(),
            color: const Color(0xFF1B5E20),
            child: state.when(
              initial: () => _buildLoading(),
              loading: () => _buildLoading(),
              loaded: (summary, children) =>
                  _buildDashboard(context, summary, children),
              failure: (message) => _buildError(context, message),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _buildFab(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HomeState state) {
    int expiringCount = 0;
    state.when(
      initial: () {},
      loading: () {},
      loaded: (summary, _) => expiringCount = summary.criticalItems.length,
      failure: (_) {},
    );
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dapur Cerdas',
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFF1B5E20),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  height: 1,
                ),
              ),
              Text(
                'Beranda',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF263238),
                size: 24,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
            ),
            if (expiringCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    expiringCount > 9 ? '9+' : '$expiringCount',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            borderRadius: BorderRadius.circular(16),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, color: Color(0xFF1B5E20), size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadDashboard(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    DashboardSummary summary,
    List<Child> children,
  ) {
    final firstChild = children.isNotEmpty ? children.first : null;
    final statSafe =
        summary.totalStocks - summary.expiringCount - summary.expiredCount;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeroBand(
            userName: widget.userName,
            childName: firstChild?.name,
            childAge: firstChild == null ? null : _formatAge(firstChild),
            statTotal: summary.totalStocks,
            statSafe: statSafe,
            statSoon: summary.expiringCount + summary.expiredCount,
          ),
          const SizedBox(height: 16),
          _FridgeAlertCard(items: summary.criticalItems),
          const SizedBox(height: 16),
          _AIRecipeBanner(childName: firstChild?.name),
          const SizedBox(height: 16),
          _InventorySection(
            summary: summary,
            onAddStock: () async {
              final saved = await showAddStockSheet(context);
              if (saved == true && context.mounted) {
                context.read<HomeCubit>().loadDashboard();
              }
            },
            onOpenStock: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockPage()),
            ),
          ),
          const SizedBox(height: 16),
          _DailyTipCard(childName: firstChild?.name),
        ],
      ),
    );
  }

  String _formatAge(Child child) {
    final m = child.ageInMonths;
    if (m < 24) return '$m bulan';
    if (m % 12 == 0) return '${m ~/ 12} tahun';
    return '${m ~/ 12} tahun ${m % 12} bulan';
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              active: _navIndex == 0,
              onTap: () => _onNavTap(0),
            ),
            _NavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Stok Kulkas',
              active: _navIndex == 1,
              onTap: () => _onNavTap(1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.show_chart_rounded,
              label: 'Nutrisi',
              active: _navIndex == 3,
              onTap: () => _onNavTap(3),
            ),
            _NavItem(
              icon: Icons.face_rounded,
              label: 'Si Kecil',
              active: _navIndex == 4,
              onTap: () => _onNavTap(4),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider(
        create: (_) => sl<StockCubit>()..loadStocks(),
        child: const _AiSheetBody(),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => _onNavTap(2),
      backgroundColor: const Color(0xFFFB8C00),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.auto_awesome, size: 24),
    );
  }
}

class _HomeHeroBand extends StatelessWidget {
  final String userName;
  final String? childName;
  final String? childAge;
  final int statTotal;
  final int statSafe;
  final int statSoon;

  const _HomeHeroBand({
    required this.userName,
    this.childName,
    this.childAge,
    required this.statTotal,
    required this.statSafe,
    required this.statSoon,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Stack(
        children: [
          const Positioned(
            right: -18,
            top: -18,
            child: Icon(
              Icons.eco_rounded,
              size: 130,
              color: Colors.white10,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Halo, $userName!',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dateLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mari penuhi gizi harian ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                    if (childName != null)
                      TextSpan(
                        text: '$childName ($childAge)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    if (childName == null)
                      TextSpan(
                        text: 'keluarga',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    TextSpan(
                      text: ' hari ini.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _HeroStatTile(label: 'Total Bahan', value: '$statTotal'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroStatTile(
                      label: 'Aman',
                      value: '$statSafe',
                      emphasize: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroStatTile(
                      label: 'Perlu Diolah',
                      value: '$statSoon',
                      warn: statSoon > 0,
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

class _HeroStatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final bool warn;

  const _HeroStatTile({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = emphasize
        ? const Color(0xFFFFFFFF).withValues(alpha: 0.95)
        : warn
            ? const Color(0xFFFEF3C7).withValues(alpha: 0.28)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.14);
    final valueColor = emphasize
        ? const Color(0xFF1B5E20)
        : warn
            ? const Color(0xFFFFE082)
            : Colors.white;
    final labelColor = emphasize
        ? const Color(0xFF4B5563)
        : warn
            ? const Color(0xFFFFF3CD)
            : Colors.white.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
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
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 8),
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
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _AiSheetBody extends StatefulWidget {
  const _AiSheetBody();

  @override
  State<_AiSheetBody> createState() => _AiSheetBodyState();
}

class _AiSheetBodyState extends State<_AiSheetBody> {
  final Set<int> _selected = {};

  void _toggle(int id) {
    setState(() {
      if (!_selected.add(id)) {
        _selected.remove(id);
      }
    });
  }

  void _buildRecipe(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiRecipeResultPage(ingredientIds: _selected.toList()),
      ),
    );
  }

  void _goToStock(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFFB8C00)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanya AI Dapur', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                      Text('Pilih bahan dari kulkasmu, AI akan racik resepnya.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<StockCubit, StockState>(
              builder: (context, state) {
                if (state is StockLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
                }
                if (state is StockFailure) {
                  return _AiSheetError(
                    message: state.message,
                    onRetry: () => context.read<StockCubit>().loadStocks(),
                  );
                }
                if (state is StockLoaded) {
                  if (state.stocks.isEmpty) {
                    return _AiSheetEmpty(onAddStock: () => _goToStock(context));
                  }
                  final ingredients = <int, String>{};
                  for (final stock in state.stocks) {
                    ingredients[stock.ingredient.id] = stock.ingredient.name;
                  }
                  final entries = ingredients.entries.toList();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entries.map((e) {
                        return _AiSelectChip(
                          label: e.value,
                          selected: _selected.contains(e.key),
                          onTap: () => _toggle(e.key),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selected.isNotEmpty) ...[
                  Text(
                    '${_selected.length} bahan terpilih',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selected.isEmpty ? null : () => _buildRecipe(context),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      _selected.isEmpty ? 'Pilih Bahan Dulu' : 'Buat Resep dengan AI',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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

class _AiSheetError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AiSheetError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat stok kulkas',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF263238)),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiSheetEmpty extends StatelessWidget {
  final VoidCallback onAddStock;

  const _AiSheetEmpty({required this.onAddStock});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.kitchen_outlined, color: Color(0xFF9CA3AF), size: 44),
            const SizedBox(height: 12),
            Text(
              'Kulkas masih kosong',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF263238)),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan dulu bahan di stok kulkas agar AI bisa meracik resep.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAddStock,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFB8C00)),
              child: const Text('Tambah Stok'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiSelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AiSelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B5E20) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1B5E20) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.add_circle_outline,
              size: 14,
              color: selected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1B5E20) : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FridgeAlertCard extends StatelessWidget {
  final List<Stock> items;

  const _FridgeAlertCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peringatan Kulkas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: items.isEmpty
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            items.isEmpty
                                ? 'Kulkas Aman'
                                : '${items.length} Bahan Perlu Diolah Segera!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: items.isEmpty
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Selengkapnya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: Color(0xFF16A34A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...items
                .take(2)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FridgeRow(item: e),
                  ),
                ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Semua bahan masih segar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF166534),
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

class _FridgeRow extends StatelessWidget {
  final Stock item;
  const _FridgeRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isExpired = item.status == StockStatus.expired;
    final days = item.daysLeft;
    return Row(
      children: [
        IngredientImage(
          imageUrl: item.ingredient.imageUrl,
          name: item.ingredient.name,
          size: 40,
          borderRadius: 10,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.ingredient.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isExpired ? 'Kedaluwarsa' : 'Sisa $days hari lagi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isExpired
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _AIRecipeBanner extends StatelessWidget {
  final String? childName;
  const _AIRecipeBanner({this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFBBF7D0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          const Positioned(
            right: -14,
            top: -14,
            child: Icon(
              Icons.soup_kitchen_rounded,
              size: 96,
              color: Colors.white70,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Racik Resep\ndengan AI',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                childName == null
                    ? 'AI otomatis menyesuaikan stok kulkas dengan kebutuhan gizi keluarga.'
                    : 'AI otomatis menyesuaikan stok kulkas dengan target nutrisi harian $childName.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF1F2937),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecipeListPage()),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    'Racik Resep Sekarang',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final saved = await showAddStockSheet(context);
                    if (saved == true && context.mounted) {
                      context.read<HomeCubit>().loadDashboard();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Tambah Bahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                    side: const BorderSide(color: Color(0xFF1B5E20), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
    );
  }
}

class _InventorySection extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback onAddStock;
  final VoidCallback onOpenStock;

  const _InventorySection({
    required this.summary,
    required this.onAddStock,
    required this.onOpenStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.kitchen_rounded,
          iconColor: const Color(0xFF16A34A),
          iconBg: const Color(0xFFDCFCE7),
          title: 'Ringkasan Bahan Kulkas',
          trailing: InkWell(
            onTap: onAddStock,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Tambah Bahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (summary.recentStocks.isNotEmpty)
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.65,
            ),
            children: summary.recentStocks.map((s) {
              final isExpiring =
                  s.status == StockStatus.expiring || s.status == StockStatus.expired;
              return _InvCard(
                icon:
                    isExpiring ? Icons.warning_amber_rounded : Icons.egg_alt,
                imageUrl: s.ingredient.imageUrl,
                title: s.ingredient.name,
                subtitle:
                    '${s.quantity.toStringAsFixed(s.quantity % 1 == 0 ? 0 : 1)} ${s.unit}${s.expiryDate != null ? ' • ${_shortDate(s.expiryDate!)}' : ''}',
                highlight: isExpiring,
              );
            }).toList(),
          )
        else
          _InventoryEmpty(
            total: summary.totalStocks,
            onAdd: onAddStock,
            onOpen: onOpenStock,
          ),
        if (summary.totalStocks > 0)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onOpenStock,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua ${summary.totalStocks} Bahan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: Color(0xFF16A34A),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _shortDate(DateTime d) => '${d.day}/${d.month}';
}

class _InventoryEmpty extends StatelessWidget {
  final int total;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  const _InventoryEmpty({
    required this.total,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDE9)),
      ),
      child: total > 0
          ? Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF16A34A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$total bahan tersedia di kulkas. Lihat detail dan status kedaluwarsanya.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onOpen,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                    side: const BorderSide(color: Color(0xFF1B5E20)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Lihat Stok',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.kitchen_outlined,
                    color: Color(0xFFD97706),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kulkas masih kosong',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tambahkan bahan pertama supaya stok terpantau dan AI bisa membantu meracik resep.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Tambah Bahan Pertama',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

class _InvCard extends StatelessWidget {
  final IconData icon;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final bool highlight;
  const _InvCard({
    required this.icon,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = imageUrl;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? const Color(0xFFFECACA) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image == null || image.isEmpty)
            Icon(icon, size: 20, color: highlight ? const Color(0xFFDC2626) : const Color(0xFF16A34A))
          else
            IngredientImage(
              imageUrl: image,
              name: title,
              size: 32,
              borderRadius: 8,
            ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  final String? childName;
  const _DailyTipCard({this.childName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFDE68A))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.lightbulb, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF92400E))),
                const SizedBox(height: 4),
                Text(
                  childName == null
                      ? 'Variasikan protein hewani setiap hari dan jadwalkan cek kedaluwarsa tiap minggu.'
                      : 'Untuk ${childName ?? 'si kecil'}, pastikan 1 sumber protein hewani di tiap makan utama.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF78350F), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
