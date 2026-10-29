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

  Future<bool> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    final result = await createChildUsecase(
      name: name,
      gender: gender,
      birthDate: birthDate,
      hpht: hpht,
      hpl: hpl,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
    );
    return result.fold(
      (failure) {
        emit(ChildFailure(failure.message));
        return false;
      },
      (_) async {
        await loadChildren();
        return true;
      },
    );
  }

  Future<bool> updateChild({
    required String id,
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    final result = await updateChildUsecase(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
      hpht: hpht,
      hpl: hpl,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
    );
    return result.fold(
      (failure) {
        emit(ChildFailure(failure.message));
        return false;
      },
      (_) async {
        await loadChildren();
        return true;
      },
    );
  }

  Future<bool> deleteChild(String id) async {
    final result = await deleteChildUsecase(id);
    return result.fold(
      (failure) {
        emit(ChildFailure(failure.message));
        return false;
      },
      (_) async {
        await loadChildren();
        return true;
      },
    );
  }
}
