import 'package:equatable/equatable.dart';

class CookingLog extends Equatable {
  final int id;
  final int recipeId;
  final int servings;
  final DateTime cookedAt;

  const CookingLog({
    required this.id,
    required this.recipeId,
    required this.servings,
    required this.cookedAt,
  });

  @override
  List<Object?> get props => [id, recipeId, servings, cookedAt];
}
