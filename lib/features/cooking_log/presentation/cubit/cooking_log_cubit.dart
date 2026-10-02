import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/log_cooking_usecase.dart';
import 'cooking_log_state.dart';

class CookingLogCubit extends Cubit<CookingLogState> {
  final LogCookingUsecase logCookingUsecase;

  CookingLogCubit({required this.logCookingUsecase}) : super(CookingLogInitial());

  Future<void> logCooking({
    required int recipeId,
    required int servings,
  }) async {
    emit(CookingLogLoading());
    final result = await logCookingUsecase(
      recipeId: recipeId,
      servings: servings,
    );
    result.fold(
      (failure) => emit(CookingLogFailure(failure.message)),
      (log) => emit(CookingLogSuccess(log)),
    );
  }

  void reset() {
    emit(CookingLogInitial());
  }
}
