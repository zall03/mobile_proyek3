import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_overview.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(NotificationOverview) loaded,
    required T Function(String) failure,
  }) {
    if (this is NotificationsInitial) return initial();
    if (this is NotificationsLoading) return loading();
    if (this is NotificationsLoaded) {
      return loaded((this as NotificationsLoaded).overview);
    }
    if (this is NotificationsFailure) {
      return failure((this as NotificationsFailure).message);
    }
    throw Exception('Unknown state');
  }
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final NotificationOverview overview;

  const NotificationsLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

class NotificationsFailure extends NotificationsState {
  final String message;

  const NotificationsFailure(this.message);

  @override
  List<Object?> get props => [message];
}