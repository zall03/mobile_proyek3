import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification_overview.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationOverview>> getNotifications();
}