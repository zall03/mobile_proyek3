import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/recipe_usecases.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final GetRecipesUsecase getRecipesUsecase;
  final GetRecipeByIdUsecase getRecipeByIdUsecase;
  final GenerateRecipeUsecase generateRecipeUsecase;

  RecipeCubit({
    required this.getRecipesUsecase,
    required this.getRecipeByIdUsecase,
    required this.generateRecipeUsecase,
  }) : super(RecipeInitial());

  Future<void> loadRecipes() async {
    emit(RecipeLoading());
    final result = await getRecipesUsecase();
    result.fold(
      (failure) => emit(RecipeFailure(failure.message)),
      (recipes) => emit(RecipeLoaded(recipes)),
    );
  }

  Future<void> getRecipeDetail(int id) async {
    emit(RecipeLoading());
    final result = await getRecipeByIdUsecase(id);
    result.fold(
      (failure) => emit(RecipeFailure(failure.message)),
      (recipe) => emit(RecipeDetail(recipe)),
    );
  }

  Future<void> generateRecipe(List<int> ingredientIds) async {
    emit(RecipeGenerating());
    final result = await generateRecipeUsecase(ingredientIds);
    result.fold(
      (failure) => emit(RecipeFailure(failure.message)),
      (recipe) => emit(RecipeDetail(recipe)),
    );
  }
}
