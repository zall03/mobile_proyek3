import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> getRecipes();
  Future<Either<Failure, Recipe>> getRecipeById(int id);
  Future<Either<Failure, Recipe>> generateRecipe(List<int> ingredientIds);
}
