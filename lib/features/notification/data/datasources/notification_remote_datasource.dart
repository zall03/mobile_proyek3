import 'package:dio/dio.dart';

import '../models/notification_model.dart';

class NotificationRemoteDatasource {
  final Dio dio;

  NotificationRemoteDatasource(this.dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get('/notifications');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat notifikasi: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await dio.put('/notifications/$id/read');
    } catch (e) {
      throw Exception('Gagal menandai notifikasi: $e');
    }
  }
}
