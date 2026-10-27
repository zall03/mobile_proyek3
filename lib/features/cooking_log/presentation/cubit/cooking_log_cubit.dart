import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/log_cooking_usecase.dart';
import 'cooking_log_state.dart';

class CookingLogCubit extends Cubit<CookingLogState> {
  final LogCookingUsecase logCooking;

  CookingLogCubit({required this.logCooking}) : super(CookingLogInitial());

  Future<void> start({
    required int recipeId,
    required int servings,
    int? durationMinutes,
  }) async {
    emit(CookingLogLoading());

    final result = await logCooking(
      recipeId: recipeId,
      servings: servings,
      durationMinutes: durationMinutes,
    );

    result.fold(
      (failure) => emit(CookingLogFailure(failure.message)),
      (log) => emit(CookingLogSuccess(log)),
    );
  }

  void reset() => emit(CookingLogInitial());
}
