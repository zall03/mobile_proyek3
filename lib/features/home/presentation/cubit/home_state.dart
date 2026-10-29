import 'package:equatable/equatable.dart';

import '../../../child/domain/entities/child.dart';
import '../../../pregnancy/domain/entities/pregnancy.dart';
import '../../domain/entities/dashboard_summary.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(DashboardSummary, List<Child>, Pregnancy?) loaded,
    required T Function(String) failure,
  }) {
    if (this is HomeInitial) return initial();
    if (this is HomeLoading) return loading();
    if (this is HomeLoaded) {
      final state = this as HomeLoaded;
      return loaded(state.summary, state.children, state.pregnancy);
    }
    if (this is HomeFailure) return failure((this as HomeFailure).message);
    throw Exception('Unknown state');
  }
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DashboardSummary summary;
  final List<Child> children;
  final Pregnancy? pregnancy;

  const HomeLoaded(this.summary, this.children, this.pregnancy);

  @override
  List<Object?> get props => [summary, children, pregnancy];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
