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
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(int id) async {
    try {
      final recipe = await remoteDatasource.getRecipeById(id);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> generateRecipe(List<int> ingredientIds) async {
    try {
      final recipe = await remoteDatasource.generateRecipe(ingredientIds);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
