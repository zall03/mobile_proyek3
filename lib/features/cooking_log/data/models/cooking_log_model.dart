import '../../../cooking_log/domain/entities/cooking_log.dart';

class CookingLogModel extends CookingLog {
  const CookingLogModel({
    required super.id,
    required super.recipeId,
    required super.servings,
    required super.cookedAt,
  });

  factory CookingLogModel.fromJson(Map<String, dynamic> json) {
    return CookingLogModel(
      id: json['id'] as int,
      recipeId: json['recipe_id'] as int,
      servings: json['servings'] as int? ?? 1,
      cookedAt: DateTime.parse(json['cooked_at'] as String),
    );
  }
}
