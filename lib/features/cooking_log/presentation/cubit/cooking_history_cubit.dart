import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/log_cooking_usecase.dart';
import 'cooking_history_state.dart';

class CookingHistoryCubit extends Cubit<CookingHistoryState> {
  final GetCookingHistoryUsecase getHistory;

  CookingHistoryCubit({required this.getHistory})
    : super(CookingHistoryInitial());

  Future<void> load({int days = 30}) async {
    emit(CookingHistoryLoading());

    final result = await getHistory(days: days);

    result.fold(
      (failure) => emit(CookingHistoryFailure(failure.message)),
      (logs) => emit(CookingHistoryLoaded(logs)),
    );
  }
}
