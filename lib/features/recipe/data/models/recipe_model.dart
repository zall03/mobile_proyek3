import '../../domain/entities/recipe.dart';

class RecipeIngredientModel extends RecipeIngredient {
  const RecipeIngredientModel({
    required super.ingredientId,
    required super.ingredientName,
    required super.quantityNeeded,
    required super.unit,
    super.imageUrl,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      ingredientId: json['ingredient_id'] as int,
      ingredientName: json['ingredient_name'] as String? ?? 'Unknown',
      quantityNeeded: (json['quantity_needed'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
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
    required super.source,
    required super.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final ingredientsList = (json['ingredients'] as List<dynamic>?)
            ?.map((i) => RecipeIngredientModel.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    return RecipeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      source: json['source'] as String? ?? 'manual',
      ingredients: ingredientsList,
    );
  }
}
