import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../child/domain/entities/child.dart';
import '../../../child/domain/usecases/child_usecases.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetDashboardSummaryUsecase getDashboardSummaryUsecase;
  final GetChildrenUsecase getChildrenUsecase;

  HomeCubit({
    required this.getDashboardSummaryUsecase,
    required this.getChildrenUsecase,
  }) : super(HomeInitial());

  Future<void> loadDashboard() async {
    emit(HomeLoading());
    final summaryResult = await getDashboardSummaryUsecase();
    final childrenResult = await getChildrenUsecase();
    summaryResult.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (summary) {
        final children = childrenResult.fold((_) => <Child>[], (list) => list);
        emit(HomeLoaded(summary, children));
      },
    );
  }
}