import '../../domain/entities/dashboard_summary.dart';
import '../../../stock/domain/repositories/stock_repository.dart';

class HomeRemoteDatasource {
  final StockRepository stockRepository;

  HomeRemoteDatasource(this.stockRepository);

  Future<DashboardSummary> getDashboardSummary() async {
    final allStocksResult = await stockRepository.getStocks();
    final expiringStocksResult = await stockRepository.getStocks(status: 'expiring');
    final expiredStocksResult = await stockRepository.getStocks(status: 'expired');

    return allStocksResult.fold(
      (failure) => throw Exception(failure.message),
      (allStocks) => expiringStocksResult.fold(
        (failure) => throw Exception(failure.message),
        (expiringStocks) => expiredStocksResult.fold(
          (failure) => throw Exception(failure.message),
          (expiredStocks) {
            final criticalItems = [...expiringStocks, ...expiredStocks];
            // 4 terbaru: id terbesar = paling baru (tanpa createdAt di entity)
            final sorted = [...allStocks]..sort((a, b) => b.id.compareTo(a.id));
            final recentStocks = sorted.take(4).toList();
            return DashboardSummary(
              totalStocks: allStocks.length,
              expiringCount: expiringStocks.length,
              expiredCount: expiredStocks.length,
              criticalItems: criticalItems,
              recentStocks: recentStocks,
            );
          },
        ),
      ),
    );
  }
}
