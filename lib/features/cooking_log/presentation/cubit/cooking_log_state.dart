import 'package:equatable/equatable.dart';

import '../../domain/entities/cooking_log.dart';

abstract class CookingLogState extends Equatable {
  const CookingLogState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(CookingLog) success,
    required T Function(String) failure,
  }) {
    if (this is CookingLogInitial) return initial();
    if (this is CookingLogLoading) return loading();
    if (this is CookingLogSuccess) return success((this as CookingLogSuccess).log);
    if (this is CookingLogFailure) return failure((this as CookingLogFailure).message);
    throw Exception('Unknown state');
  }
}

class CookingLogInitial extends CookingLogState {}

class CookingLogLoading extends CookingLogState {}

class CookingLogSuccess extends CookingLogState {
  final CookingLog log;

  const CookingLogSuccess(this.log);

  @override
  List<Object?> get props => [log];
}

class CookingLogFailure extends CookingLogState {
  final String message;

  const CookingLogFailure(this.message);

  @override
  List<Object?> get props => [message];
}
