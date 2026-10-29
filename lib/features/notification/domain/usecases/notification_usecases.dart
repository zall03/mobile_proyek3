import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUsecase {
  final NotificationRepository repository;

  GetNotificationsUsecase(this.repository);

  Future<Either<Failure, List<AppNotification>>> call() {
    return repository.getNotifications();
  }
}

class MarkNotificationAsReadUsecase {
  final NotificationRepository repository;

  MarkNotificationAsReadUsecase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.markAsRead(id);
  }
}
