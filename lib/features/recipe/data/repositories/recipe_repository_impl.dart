import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_datasource.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDatasource remoteDatasource;

  RecipeRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<Recipe>>> getRecipes() async {
    try {
      final recipes = await remoteDatasource.getRecipes();
      return Right(recipes.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(int id) async {
    try {
      final recipe = await remoteDatasource.getRecipeById(id);
      return Right(recipe.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> generateRecipe(
    List<int> ingredientIds, {
    String? forWhom,
    List<String>? restrictions,
    int? servings,
  }) async {
    try {
      final recipe = await remoteDatasource.generateRecipe(
        ingredientIds,
        forWhom: forWhom,
        restrictions: restrictions,
        servings: servings,
      );
      return Right(recipe.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
