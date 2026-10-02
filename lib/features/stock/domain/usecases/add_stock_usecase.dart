import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class AddStockUsecase {
  final StockRepository repository;

  AddStockUsecase(this.repository);

  Future<Either<Failure, Stock>> call({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) {
    return repository.addStock(
      ingredientId: ingredientId,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
    );
  }
}