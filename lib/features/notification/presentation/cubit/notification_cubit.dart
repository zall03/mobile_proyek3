import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUsecase getNotificationsUsecase;
  final MarkNotificationAsReadUsecase markAsReadUsecase;

  NotificationCubit({
    required this.getNotificationsUsecase,
    required this.markAsReadUsecase,
  }) : super(const NotificationInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationLoading());
    final result = await getNotificationsUsecase();
    result.fold(
      (failure) => emit(NotificationFailure(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> markAsRead(String id) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      await markAsReadUsecase(id);
      final updated = currentState.notifications.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      emit(NotificationLoaded(updated));
    }
  }

  int get unreadCount {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      return currentState.notifications.where((n) => !n.isRead).length;
    }
    return 0;
  }
}
