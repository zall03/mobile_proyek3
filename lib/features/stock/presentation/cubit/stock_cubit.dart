import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ingredient.dart';
import '../../domain/entities/ingredient_category.dart';
import '../../domain/entities/stock.dart';
import '../../domain/usecases/add_stock_usecase.dart';
import '../../domain/usecases/delete_stock_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_ingredients_usecase.dart';
import '../../domain/usecases/get_stocks_usecase.dart';
import '../../domain/usecases/update_stock_usecase.dart';
import 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final GetCategoriesUsecase getCategoriesUsecase;
  final GetIngredientsUsecase getIngredientsUsecase;
  final GetStocksUsecase getStocksUsecase;
  final AddStockUsecase addStockUsecase;
  final UpdateStockUsecase updateStockUsecase;
  final DeleteStockUsecase deleteStockUsecase;

  StockCubit({
    required this.getCategoriesUsecase,
    required this.getIngredientsUsecase,
    required this.getStocksUsecase,
    required this.addStockUsecase,
    required this.updateStockUsecase,
    required this.deleteStockUsecase,
  }) : super(StockInitial());

  List<IngredientCategory> _categories = [];
  List<Ingredient> _ingredientResults = [];
  String? _activeStatus;

  Future<void> loadStocks({String? status}) async {
    if (status != null) {
      _activeStatus = status;
    }
    emit(StockLoading());
    final result = await getStocksUsecase(status: _activeStatus);
    result.fold(
      (failure) => emit(StockFailure(failure.message)),
      (stocks) => _emitLoaded(stocks),
    );
  }

  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) {
      return;
    }
    final result = await getCategoriesUsecase();
    result.fold(
      (failure) => emit(StockFailure(failure.message)),
      (categories) {
        _categories = categories;
        if (state is StockLoaded) {
          emit((state as StockLoaded).copyWith(categories: categories));
        }
      },
    );
  }

  Future<void> searchIngredients(String query) async {
    if (query.trim().isEmpty) {
      _ingredientResults = [];
      final current = state;
      if (current is StockLoaded) {
        emit(current.copyWith(ingredientResults: const []));
      }
      return;
    }
    final result = await getIngredientsUsecase(query: query);
    result.fold(
      (failure) => emit(StockFailure(failure.message, isSearchRelated: true)),
      (ingredients) {
        _ingredientResults = ingredients;
        final current = state;
        if (current is StockLoaded) {
          emit(current.copyWith(ingredientResults: ingredients));
        } else {
          emit(
            StockLoaded(
              stocks: const [],
              categories: const [],
              ingredientResults: ingredients,
            ),
          );
        }
      },
    );
  }

  Future<void> addStock({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    final result = await addStockUsecase(
      ingredientId: ingredientId,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
    );
    await result.fold(
      (failure) async => emit(StockFailure(failure.message)),
      (_) async => _reloadWithMessage('Stok berhasil ditambahkan'),
    );
  }

  Future<void> updateStock({
    required int id,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    final result = await updateStockUsecase(
      id: id,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
    );
    await result.fold(
      (failure) async => emit(StockFailure(failure.message)),
      (_) async => _reloadWithMessage('Stok berhasil diperbarui'),
    );
  }

  Future<void> deleteStock({required int id}) async {
    final result = await deleteStockUsecase(id: id);
    await result.fold(
      (failure) async => emit(StockFailure(failure.message)),
      (_) async => _reloadWithMessage('Stok berhasil dihapus'),
    );
  }

  void clearMessage() {
    final current = state;
    if (current is StockLoaded && current.message != null) {
      emit(current.copyWith(message: null));
    }
  }

  Future<void> _reloadWithMessage(String message) async {
    emit(StockLoading());
    final result = await getStocksUsecase(status: _activeStatus);
    result.fold(
      (failure) => emit(StockFailure(failure.message)),
      (stocks) => _emitLoaded(stocks, message: message),
    );
  }

  void _emitLoaded(List<Stock> stocks, {String? message}) {
    emit(
      StockLoaded(
        stocks: stocks,
        categories: _categories,
        ingredientResults: _ingredientResults,
        activeStatus: _activeStatus,
        message: message,
      ),
    );
  }
}