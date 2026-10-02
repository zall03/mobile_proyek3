import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/stock_repository.dart';

class DeleteStockUsecase {
  final StockRepository repository;

  DeleteStockUsecase(this.repository);

  Future<Either<Failure, void>> call({required int id}) {
    return repository.deleteStock(id: id);
  }
}