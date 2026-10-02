import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final int id;
  final int categoryId;
  final String name;
  final String defaultUnit;
  final double caloriesPer100g;
  final double proteinG;
  final double ironMg;
  final double zincMg;
  final double vitaminAMcg;
  final double vitaminCMg;
  final String? categoryName;
  final String? imageUrl;

  const Ingredient({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.defaultUnit,
    required this.caloriesPer100g,
    required this.proteinG,
    required this.ironMg,
    required this.zincMg,
    required this.vitaminAMcg,
    required this.vitaminCMg,
    this.categoryName,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, imageUrl];
}