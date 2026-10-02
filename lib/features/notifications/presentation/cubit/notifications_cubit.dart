import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUsecase getNotificationsUsecase;

  NotificationsCubit({required this.getNotificationsUsecase})
    : super(NotificationsInitial());

  Future<void> load() async {
    emit(NotificationsLoading());
    final result = await getNotificationsUsecase();
    result.fold(
      (failure) => emit(NotificationsFailure(failure.message)),
      (overview) => emit(NotificationsLoaded(overview)),
    );
  }
}