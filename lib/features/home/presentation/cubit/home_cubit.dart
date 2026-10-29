import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../child/domain/entities/child.dart';
import '../../../child/domain/usecases/child_usecases.dart';
import '../../../pregnancy/domain/usecases/pregnancy_usecases.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetDashboardSummaryUsecase getDashboardSummaryUsecase;
  final GetChildrenUsecase getChildrenUsecase;
  final GetActivePregnancyUsecase getActivePregnancyUsecase;

  HomeCubit({
    required this.getDashboardSummaryUsecase,
    required this.getChildrenUsecase,
    required this.getActivePregnancyUsecase,
  }) : super(HomeInitial());

  Future<void> loadDashboard() async {
    emit(HomeLoading());
    final summaryResult = await getDashboardSummaryUsecase();
    final childrenResult = await getChildrenUsecase();
    final pregnancyResult = await getActivePregnancyUsecase();
    summaryResult.fold((failure) => emit(HomeFailure(failure.message)), (
      summary,
    ) {
      final children = childrenResult.fold((_) => <Child>[], (list) => list);
      final pregnancy = pregnancyResult.fold((_) => null, (value) => value);
      emit(HomeLoaded(summary, children, pregnancy));
    });
  }
}
