import 'package:equatable/equatable.dart';

class RecipeIngredient extends Equatable {
  final int ingredientId;
  final String ingredientName;
  final double quantityNeeded;
  final String unit;
  final String? imageUrl;
  final bool inStock;

  const RecipeIngredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantityNeeded,
    required this.unit,
    this.imageUrl,
    this.inStock = false,
  });

  @override
  List<Object?> get props => [
    ingredientId,
    ingredientName,
    quantityNeeded,
    unit,
    imageUrl,
    inStock,
  ];
}

class Recipe extends Equatable {
  final int id;
  final String name;
  final String description;
  final String instructions;
  final int cookTimeMinutes;
  final int servings;
  final String source;
  final List<RecipeIngredient> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.cookTimeMinutes,
    required this.servings,
    required this.source,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    instructions,
    cookTimeMinutes,
    servings,
    source,
    ingredients,
  ];
}
