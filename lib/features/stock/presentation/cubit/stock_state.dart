import 'package:equatable/equatable.dart';

import '../../domain/entities/ingredient.dart';
import '../../domain/entities/ingredient_category.dart';
import '../../domain/entities/stock.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Stock> stocks;
  final List<IngredientCategory> categories;
  final List<Ingredient> ingredientResults;
  final String? activeStatus;
  final String? message;

  const StockLoaded({
    required this.stocks,
    required this.categories,
    this.ingredientResults = const [],
    this.activeStatus,
    this.message,
  });

  StockLoaded copyWith({
    List<Stock>? stocks,
    List<IngredientCategory>? categories,
    List<Ingredient>? ingredientResults,
    String? activeStatus,
    String? message,
  }) {
    return StockLoaded(
      stocks: stocks ?? this.stocks,
      categories: categories ?? this.categories,
      ingredientResults: ingredientResults ?? this.ingredientResults,
      activeStatus: activeStatus ?? this.activeStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    stocks,
    categories,
    ingredientResults,
    activeStatus,
    message,
  ];
}

class StockFailure extends StockState {
  final String message;
  final bool isSearchRelated;

  const StockFailure(this.message, {this.isSearchRelated = false});

  @override
  List<Object?> get props => [message, isSearchRelated];
}