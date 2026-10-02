import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/child_usecases.dart';
import 'child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  final GetChildrenUsecase getChildrenUsecase;
  final GetChildByIdUsecase getChildByIdUsecase;
  final CreateChildUsecase createChildUsecase;
  final UpdateChildUsecase updateChildUsecase;
  final DeleteChildUsecase deleteChildUsecase;

  ChildCubit({
    required this.getChildrenUsecase,
    required this.getChildByIdUsecase,
    required this.createChildUsecase,
    required this.updateChildUsecase,
    required this.deleteChildUsecase,
  }) : super(ChildInitial());

  Future<void> loadChildren() async {
    emit(ChildLoading());
    final result = await getChildrenUsecase();
    result.fold(
      (failure) => emit(ChildFailure(failure.message)),
      (children) => emit(ChildLoaded(children)),
    );
  }

  Future<void> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    final result = await createChildUsecase(
      name: name,
      gender: gender,
      birthDate: birthDate,
    );
    result.fold(
      (failure) => emit(ChildFailure(failure.message)),
      (_) => loadChildren(),
    );
  }

  Future<void> updateChild({
    required int id,
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    final result = await updateChildUsecase(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
    );
    result.fold(
      (failure) => emit(ChildFailure(failure.message)),
      (_) => loadChildren(),
    );
  }

  Future<void> deleteChild(int id) async {
    final result = await deleteChildUsecase(id);
    result.fold(
      (failure) => emit(ChildFailure(failure.message)),
      (_) => loadChildren(),
    );
  }
}
