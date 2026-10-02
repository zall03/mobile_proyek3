import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.defaultUnit,
    required super.caloriesPer100g,
    required super.proteinG,
    required super.ironMg,
    required super.zincMg,
    required super.vitaminAMcg,
    required super.vitaminCMg,
    super.categoryName,
    super.imageUrl,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return IngredientModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      defaultUnit: json['default_unit'] as String,
      caloriesPer100g: _toDouble(json['calories_per_100g']),
      proteinG: _toDouble(json['protein_g']),
      ironMg: _toDouble(json['iron_mg']),
      zincMg: _toDouble(json['zinc_mg']),
      vitaminAMcg: _toDouble(json['vitamin_a_mcg']),
      vitaminCMg: _toDouble(json['vitamin_c_mg']),
      categoryName: category?['name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}