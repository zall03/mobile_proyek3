import 'package:equatable/equatable.dart';

import '../../../stock/domain/entities/stock.dart';

class DashboardSummary extends Equatable {
  final int totalStocks;
  final int expiringCount;
  final int expiredCount;
  final List<Stock> criticalItems;
  final List<Stock> recentStocks;

  const DashboardSummary({
    required this.totalStocks,
    required this.expiringCount,
    required this.expiredCount,
    required this.criticalItems,
    this.recentStocks = const [],
  });

  @override
  List<Object?> get props => [totalStocks, expiringCount, expiredCount, criticalItems, recentStocks];
}
