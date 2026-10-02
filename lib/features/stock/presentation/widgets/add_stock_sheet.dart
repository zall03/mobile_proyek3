import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/ingredient_image.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/ingredient.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';

Future<bool?> showAddStockSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => sl<StockCubit>(),
      child: const _AddStockSheetContent(),
    ),
  );
}

class _AddStockSheetContent extends StatefulWidget {
  const _AddStockSheetContent();

  @override
  State<_AddStockSheetContent> createState() => _AddStockSheetContentState();
}

class _AddStockSheetContentState extends State<_AddStockSheetContent> {
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  Ingredient? _selectedIngredient;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _quantityController.dispose();
    _unitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      context.read<StockCubit>().searchIngredients(query);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Pilih tanggal kedaluwarsa',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _selectIngredient(Ingredient ingredient) {
    setState(() {
      _selectedIngredient = ingredient;
      _unitController.text = ingredient.defaultUnit;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _save() {
    if (_selectedIngredient == null) {
      _showMessage('Pilih bahan makanan terlebih dahulu');
      return;
    }
    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showMessage('Jumlah harus berupa angka lebih dari 0');
      return;
    }
    if (_unitController.text.trim().isEmpty) {
      _showMessage('Satuan tidak boleh kosong');
      return;
    }
    context.read<StockCubit>().addStock(
          ingredientId: _selectedIngredient!.id,
          quantity: quantity,
          unit: _unitController.text.trim(),
          expiryDate: _selectedDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: BlocConsumer<StockCubit, StockState>(
          listener: (context, state) {
            if (state is StockFailure && !state.isSearchRelated) {
              _showMessage(state.message);
            } else if (state is StockLoaded && state.message != null) {
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            final isLoading = state is StockLoading;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_box_outlined,
                          size: 18,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tambah Bahan ke Stok',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              'Isi bahan yang baru masuk ke kulkas.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel('Pilih Bahan'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _searchController,
                          decoration: _inputDecoration('Cari bahan...', withSearchIcon: true),
                        ),
                        if (_selectedIngredient != null) ...[
                          const SizedBox(height: 10),
                          _SelectedIngredientTile(
                            ingredient: _selectedIngredient!,
                            onRemove: () => setState(() => _selectedIngredient = null),
                          ),
                        ],
                        _buildSearchResults(),
                        const SizedBox(height: 20),
                        _buildLabel('Jumlah & Satuan'),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: _inputDecoration('Contoh: 500'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _unitController,
                                decoration: _inputDecoration('Satuan'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Tanggal Kedaluwarsa'),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isLoading ? null : _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event,
                                  size: 18,
                                  color: Color(0xFF1B5E20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                        : 'Tanpa tanggal kedaluwarsa',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: _selectedDate != null
                                          ? const Color(0xFF111827)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                                if (_selectedDate != null)
                                  IconButton(
                                    onPressed: () => setState(() => _selectedDate = null),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _save,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add, size: 18),
                            label: Text('Tambah ke Stok'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, state) {
        if (state is! StockLoaded ||
            state.ingredientResults.isEmpty ||
            _selectedIngredient != null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Material(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.ingredientResults.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final ingredient = state.ingredientResults[index];
                return ListTile(
                  dense: true,
                  leading: IngredientImage(
                    imageUrl: ingredient.imageUrl,
                    name: ingredient.name,
                    size: 32,
                    borderRadius: 8,
                  ),
                  title: Text(
                    ingredient.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  subtitle: Text(
                    '${ingredient.categoryName ?? ''}'
                    '${(ingredient.categoryName ?? '').isEmpty ? '' : ' \u00B7 '}'
                    '${ingredient.caloriesPer100g.toInt()} kkal/100g',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () => _selectIngredient(ingredient),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {bool withSearchIcon = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: const Color(0xFF6B7280).withValues(alpha: 0.7),
      ),
      prefixIcon: withSearchIcon
          ? const Icon(Icons.search, size: 20, color: Color(0xFF6B7280))
          : null,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1B5E20)),
      ),
    );
  }
}

class _SelectedIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onRemove;

  const _SelectedIngredientTile({
    required this.ingredient,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B5E20),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ingredient.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}