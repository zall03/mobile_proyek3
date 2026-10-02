import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class GetStocksUsecase {
  final StockRepository repository;

  GetStocksUsecase(this.repository);

  Future<Either<Failure, List<Stock>>> call({
    int? categoryId,
    String? status,
  }) {
    return repository.getStocks(categoryId: categoryId, status: status);
  }
}