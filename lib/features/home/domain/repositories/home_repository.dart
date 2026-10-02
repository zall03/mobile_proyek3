import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';

abstract class HomeRepository {
  Future<Either<Failure, DashboardSummary>> getDashboardSummary();
}
