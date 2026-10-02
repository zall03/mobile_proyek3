import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/stock.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';

class AddEditStockPage extends StatefulWidget {
  final Stock? existingStock;

  const AddEditStockPage({super.key, this.existingStock});

  @override
  State<AddEditStockPage> createState() => _AddEditStockPageState();
}

class _AddEditStockPageState extends State<AddEditStockPage> {
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _searchController = TextEditingController();
  late final StockCubit _stockCubit;
  Timer? _debounce;
  Ingredient? _selectedIngredient;
  DateTime? _selectedDate;
  bool _isSaving = false;

  bool get _isEdit => widget.existingStock != null;

  @override
  void initState() {
    super.initState();
    _stockCubit = sl<StockCubit>();
    final existing = widget.existingStock;
    if (existing != null) {
      _selectedIngredient = existing.ingredient;
      _quantityController.text = _formatQuantity(existing.quantity);
      _unitController.text = existing.unit;
      _selectedDate = existing.expiryDate;
    } else {
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _quantityController.dispose();
    _unitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatQuantity(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      _stockCubit.searchIngredients(query);
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

  bool _validate(BuildContext context) {
    if (_selectedIngredient == null) {
      _showSnackbar(context, 'Pilih bahan makanan terlebih dahulu');
      return false;
    }
    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showSnackbar(context, 'Jumlah harus berupa angka lebih dari 0');
      return false;
    }
    if (_unitController.text.trim().isEmpty) {
      _showSnackbar(context, 'Satuan tidak boleh kosong');
      return false;
    }
    return true;
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _save(BuildContext context) {
    if (!_validate(context)) return;
    if (_isSaving) return;

    final cubit = _stockCubit;
    final quantity = double.parse(_quantityController.text.trim());
    final unit = _unitController.text.trim();
    final expiryDate = _selectedDate;

    setState(() => _isSaving = true);

    if (_isEdit) {
      cubit.updateStock(
        id: widget.existingStock!.id,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
      );
    } else {
      cubit.addStock(
        ingredientId: _selectedIngredient!.id,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _stockCubit,
      child: BlocConsumer<StockCubit, StockState>(
        listener: (context, state) {
          if (state is StockFailure) {
            if (state.isSearchRelated) {
              _showSnackbar(context, state.message);
            } else {
              setState(() => _isSaving = false);
              _showSnackbar(context, state.message);
            }
          } else if (state is StockLoaded && state.message != null) {
            setState(() => _isSaving = false);
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final isLoading = state is StockLoading;

          return Scaffold(
            backgroundColor: AppColors.bgGradientStart,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _isEdit ? 'Ubah Stok' : 'Tambah Stok',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIngredientPicker(context),
                    const SizedBox(height: 20),
                    Text(
                      'Jumlah & Satuan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
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
                    Text(
                      'Tanggal Kedaluwarsa',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event,
                              size: 20,
                              color: AppColors.primaryMedium,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat('dd/MM/yyyy').format(
                                        _selectedDate!,
                                      )
                                    : 'Tanpa tanggal kedaluwarsa',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  color: _selectedDate != null
                                      ? AppColors.primaryDark
                                      : AppColors.textGrey,
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              IconButton(
                                onPressed: () =>
                                    setState(() => _selectedDate = null),
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.textGrey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _save(context),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEdit ? 'Simpan Perubahan' : 'Tambah ke Stok',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIngredientPicker(BuildContext context) {
    if (_isEdit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 20,
              color: AppColors.primaryMedium,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.existingStock!.ingredient.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pilih Bahan',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
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
        BlocBuilder<StockCubit, StockState>(
          builder: (context, state) {
            if (state is! StockLoaded ||
                state.ingredientResults.isEmpty ||
                _selectedIngredient != null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Material(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(14),
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
                      title: Text(
                        ingredient.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      subtitle: Text(
                        '${ingredient.categoryName ?? ''}'
                        '${(ingredient.categoryName ?? '').isEmpty ? '' : ' \u00B7 '}'
                        '${ingredient.caloriesPer100g.toInt()} kkal/100g',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                      onTap: () => _selectIngredient(ingredient),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {bool withSearchIcon = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textGrey.withValues(alpha: 0.7),
      ),
      prefixIcon: withSearchIcon
          ? const Icon(Icons.search, size: 20, color: AppColors.textGrey)
          : null,
      filled: true,
      fillColor: AppColors.cardWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryMedium),
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
      color: AppColors.primaryMedium,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ingredient.name,
                style: GoogleFonts.poppins(
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