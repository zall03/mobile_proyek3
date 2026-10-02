import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification_overview.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUsecase {
  final NotificationRepository repository;

  GetNotificationsUsecase(this.repository);

  Future<Either<Failure, NotificationOverview>> call() async {
    try {
      return await repository.getNotifications();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}