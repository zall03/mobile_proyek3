import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_overview.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, NotificationOverview>> getNotifications() async {
    try {
      final overview = await remoteDatasource.getNotifications();
      return Right(overview);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}