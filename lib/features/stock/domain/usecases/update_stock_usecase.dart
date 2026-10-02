import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class UpdateStockUsecase {
  final StockRepository repository;

  UpdateStockUsecase(this.repository);

  Future<Either<Failure, Stock>> call({
    required int id,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) {
    return repository.updateStock(
      id: id,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
    );
  }
}