import 'package:dio/dio.dart';

import '../../../stock/data/models/stock_model.dart';
import '../../domain/entities/notification_overview.dart';
import '../models/measurement_reminder_model.dart';

class NotificationRemoteDatasource {
  final Dio dio;

  NotificationRemoteDatasource(this.dio);

  Future<NotificationOverview> getNotifications() async {
    try {
      final response = await dio.get('/notifications');
      final data = response.data['data'] as Map<String, dynamic>;

      final expiring = (data['expiring'] as List<dynamic>? ?? [])
          .map((e) => StockModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final lowStock = (data['low_stock'] as List<dynamic>? ?? [])
          .map((e) => StockModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final measurementDue = (data['measurement_due'] as List<dynamic>? ?? [])
          .map((e) => MeasurementReminderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return NotificationOverview(
        expiring: expiring,
        lowStock: lowStock,
        measurementDue: measurementDue,
      );
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }
}