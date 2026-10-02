import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ingredient_image.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/ingredient_category.dart';
import '../../domain/entities/stock.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import 'add_edit_stock_page.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StockCubit>(),
      child: const _StockBody(),
    );
  }
}

class _StockBody extends StatefulWidget {
  const _StockBody();

  @override
  State<_StockBody> createState() => _StockBodyState();
}

class _StockBodyState extends State<_StockBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<StockCubit>();
      cubit.loadCategories();
      cubit.loadStocks();
    });
  }

  Future<void> _openAddEdit(BuildContext context, Stock? stock) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditStockPage(existingStock: stock),
      ),
    );
    if (saved == true && context.mounted) {
      context.read<StockCubit>().loadStocks();
    }
  }

  Future<void> _confirmDelete(BuildContext context, Stock stock) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus stok',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Hapus ${stock.ingredient.name} dari stok Anda?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<StockCubit>().deleteStock(id: stock.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Stok Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(context, null),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Tambah Stok',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<StockCubit, StockState>(
        listener: (context, state) {
          if (state is StockFailure && !state.isSearchRelated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          } else if (state is StockLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.primaryMedium,
              ),
            );
            context.read<StockCubit>().clearMessage();
          }
        },
        builder: (context, state) {
          if (state is StockLoading) {
            return const _CenteredStatus(
              icon: Icons.hourglass_empty,
              message: 'Memuat stok...',
              showSpinner: true,
            );
          }
          if (state is StockFailure) {
            return _CenteredStatus(
              icon: Icons.cloud_off,
              message: state.message,
              actionLabel: 'Coba lagi',
              onAction: () => context.read<StockCubit>().loadStocks(),
            );
          }
          if (state is StockLoaded) {
            return _StockContent(
              state: state,
              onTapStock: (stock) => _openAddEdit(context, stock),
              onDeleteStock: (stock) => _confirmDelete(context, stock),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StockContent extends StatefulWidget {
  final StockLoaded state;
  final ValueChanged<Stock> onTapStock;
  final ValueChanged<Stock> onDeleteStock;

  const _StockContent({
    required this.state,
    required this.onTapStock,
    required this.onDeleteStock,
  });

  @override
  State<_StockContent> createState() => _StockContentState();
}

class _StockContentState extends State<_StockContent> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stocks = widget.state.stocks;

    if (stocks.isEmpty) {
      return const _EmptyState(
        hint: 'Belum ada stok. Gunakan tombol Tambah Stok untuk mencatat bahan makanan '
            'yang Anda miliki beserta tanggal kedaluwarsanya.',
      );
    }

    final query = _searchController.text.trim().toLowerCase();
    final visible = stocks.where((stock) {
      if (_selectedCategoryId != null &&
          stock.ingredient.categoryId != _selectedCategoryId) {
        return false;
      }
      if (query.isNotEmpty &&
          !stock.ingredient.name.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        _buildSearchBar(),
        _CategoryFilter(
          categories: widget.state.categories,
          selectedId: _selectedCategoryId,
          onSelected: (id) => setState(() => _selectedCategoryId = id),
        ),
        Expanded(
          child: visible.isEmpty
              ? _EmptyState(
                  hint: 'Tidak ada bahan yang cocok dengan pencarian/kategori.',
                  onAction: () => setState(() {
                    _searchController.clear();
                    _selectedCategoryId = null;
                  }),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  children: [
                    for (final section in _buildSections(visible))
                      ..._buildSectionWidgets(section),
                  ],
                ),
        ),
      ],
    );
  }

  List<(String, List<Stock>)> _buildSections(List<Stock> visible) {
    final priority =
        visible.where((s) => s.status != StockStatus.fresh).toList();
    final fresh =
        visible.where((s) => s.status == StockStatus.fresh).toList();

    return [
      if (priority.isNotEmpty) ('Prioritas Olah (Mendekati Expired)', priority),
      if (fresh.isNotEmpty) ('Bahan Aman & Segar', fresh),
    ];
  }

  List<Widget> _buildSectionWidgets((String, List<Stock>) section) {
    final (title, items) = section;
    return [
      _SectionHeader(title: title, count: items.length),
      const SizedBox(height: 8),
      for (final stock in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _StockCard(
            stock: stock,
            onTap: () => widget.onTapStock(stock),
            onDelete: () => widget.onDeleteStock(stock),
          ),
        ),
      const SizedBox(height: 6),
    ];
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari bahan...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey),
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textGrey),
                  onPressed: () => setState(() => _searchController.clear()),
                ),
          filled: true,
          fillColor: AppColors.cardWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<IngredientCategory> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (final (id, label) in [
            (null, 'Semua'),
            ...categories.map((c) => (c.id, c.name)),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selectedId == id,
                onSelected: (_) => onSelected(id),
                selectedColor: AppColors.primaryDark,
                backgroundColor: AppColors.cardWhite,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: selectedId == id ? Colors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
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
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Stock stock;

  const _StatusBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (stock.status) {
      StockStatus.expired => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
          'Kedaluwarsa',
        ),
      StockStatus.expiring => (
          const Color(0xFFFFF4E5),
          const Color(0xFFB45309),
          'Sisa ${stock.daysLeft} hari',
        ),
      StockStatus.fresh => (
          const Color(0xFFE8F5E9),
          const Color(0xFF1B5E20),
          'Aman',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StockCard({
    required this.stock,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final qty =
        stock.quantity.toStringAsFixed(stock.quantity % 1 == 0 ? 0 : 1);
    final expiry = stock.expiryDate;

    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              IngredientImage(
                imageUrl: stock.ingredient.imageUrl,
                name: stock.ingredient.name,
                size: 52,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stock.ingredient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(stock: stock),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$qty ${stock.unit}'
                      ' \u00B7 ${stock.ingredient.categoryName ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    if (expiry != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Kedaluwarsa ${DateFormat('dd/MM/yyyy').format(expiry)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAction;
  final String hint;

  const _EmptyState({required this.hint, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada stok',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                child: Text(
                  'Lihat semua stok',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
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

class _CenteredStatus extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool showSpinner;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredStatus({
    required this.icon,
    required this.message,
    this.showSpinner = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primaryDark,
                ),
              )
            else
              Icon(icon, size: 56, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}