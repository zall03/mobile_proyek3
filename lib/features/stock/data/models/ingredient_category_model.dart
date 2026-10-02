import '../../domain/entities/ingredient_category.dart';

class IngredientCategoryModel extends IngredientCategory {
  const IngredientCategoryModel({required super.id, required super.name});

  factory IngredientCategoryModel.fromJson(Map<String, dynamic> json) {
    return IngredientCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}