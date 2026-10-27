import 'package:equatable/equatable.dart';

import '../../domain/entities/cooking_log.dart';

abstract class CookingHistoryState extends Equatable {
  const CookingHistoryState();

  @override
  List<Object?> get props => [];
}

class CookingHistoryInitial extends CookingHistoryState {}

class CookingHistoryLoading extends CookingHistoryState {}

class CookingHistoryLoaded extends CookingHistoryState {
  final List<CookingLog> logs;

  const CookingHistoryLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class CookingHistoryFailure extends CookingHistoryState {
  final String message;

  const CookingHistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
