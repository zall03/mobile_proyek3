import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/home_repository.dart';

class GetDashboardSummaryUsecase {
  final HomeRepository repository;

  GetDashboardSummaryUsecase(this.repository);

  Future<Either<Failure, DashboardSummary>> call() {
    return repository.getDashboardSummary();
  }
}
