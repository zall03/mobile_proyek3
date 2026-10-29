import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesUsecase {
  final RecipeRepository repository;

  GetRecipesUsecase(this.repository);

  Future<Either<Failure, List<Recipe>>> call() {
    return repository.getRecipes();
  }
}

class GetRecipeByIdUsecase {
  final RecipeRepository repository;

  GetRecipeByIdUsecase(this.repository);

  Future<Either<Failure, Recipe>> call(int id) {
    return repository.getRecipeById(id);
  }
}

class GenerateRecipeUsecase {
  final RecipeRepository repository;

  GenerateRecipeUsecase(this.repository);

  Future<Either<Failure, Recipe>> call(
    List<int> ingredientIds, {
    String? forWhom,
    List<String>? restrictions,
    int? servings,
  }) {
    return repository.generateRecipe(
      ingredientIds,
      forWhom: forWhom,
      restrictions: restrictions,
      servings: servings,
    );
  }
}
