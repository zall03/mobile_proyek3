import 'package:equatable/equatable.dart';

import '../../domain/entities/recipe.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() generating,
    required T Function(List<Recipe>) loaded,
    required T Function(Recipe) recipeDetail,
    required T Function(String) failure,
  }) {
    if (this is RecipeInitial) return initial();
    if (this is RecipeLoading) return loading();
    if (this is RecipeGenerating) return generating();
    if (this is RecipeLoaded) return loaded((this as RecipeLoaded).recipes);
    if (this is RecipeDetail) return recipeDetail((this as RecipeDetail).recipe);
    if (this is RecipeFailure) return failure((this as RecipeFailure).message);
    throw Exception('Unknown state');
  }
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeGenerating extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;

  const RecipeLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeDetail extends RecipeState {
  final Recipe recipe;

  const RecipeDetail(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeFailure extends RecipeState {
  final String message;

  const RecipeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
