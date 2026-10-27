import '../../domain/entities/recipe.dart';

class RecipeIngredientModel extends RecipeIngredient {
  const RecipeIngredientModel({
    required super.ingredientId,
    required super.ingredientName,
    required super.quantityNeeded,
    required super.unit,
    super.imageUrl,
    super.inStock,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      ingredientId: json['ingredient_id'] as int,
      ingredientName: json['ingredient_name'] as String? ?? 'Unknown',
      quantityNeeded: (json['quantity_needed'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      inStock: json['in_stock'] as bool? ?? false,
    );
  }
}

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.instructions,
    required super.cookTimeMinutes,
    required super.servings,
    required super.source,
    required super.ingredients,
  });

  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      description: description,
      instructions: instructions,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      source: source,
      ingredients: ingredients
          .map(
            (ing) => RecipeIngredient(
              ingredientId: ing.ingredientId,
              ingredientName: ing.ingredientName,
              quantityNeeded: ing.quantityNeeded,
              unit: ing.unit,
              imageUrl: ing.imageUrl,
              inStock: ing.inStock,
            ),
          )
          .toList(),
    );
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final ingredientsList =
        (json['ingredients'] as List<dynamic>?)
            ?.map(
              (i) => RecipeIngredientModel.fromJson(i as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return RecipeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 2,
      source: json['source'] as String? ?? 'manual',
      ingredients: ingredientsList,
    );
  }
}
