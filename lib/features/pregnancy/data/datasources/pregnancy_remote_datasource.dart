import 'package:dio/dio.dart';

import '../models/pregnancy_model.dart';

class PregnancyRemoteDatasource {
  final Dio dio;

  PregnancyRemoteDatasource(this.dio);

  Future<PregnancyModel?> getActive() async {
    try {
      final response = await dio.get('/pregnancies/active');
      final data = response.data['data'];
      if (data == null) return null;
      return PregnancyModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal memuat profil kehamilan: $e');
    }
  }

  Future<List<PregnancyModel>> getAll() async {
    try {
      final response = await dio.get('/pregnancies');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((p) => PregnancyModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar kehamilan: $e');
    }
  }

  Future<PregnancyModel> create({
    required String motherName,
    required DateTime hphtDate,
  }) async {
    try {
      final response = await dio.post(
        '/pregnancies',
        data: {
          'mother_name': motherName,
          'hpht_date': _date(hphtDate),
        },
      );
      return PregnancyModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(_message(e, 'Gagal menyimpan profil kehamilan'));
    }
  }

  Future<PregnancyModel> update({
    required String id,
    required String motherName,
    required DateTime hphtDate,
  }) async {
    try {
      final response = await dio.put(
        '/pregnancies/$id',
        data: {
          'mother_name': motherName,
          'hpht_date': _date(hphtDate),
        },
      );
      return PregnancyModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(_message(e, 'Gagal memperbarui profil kehamilan'));
    }
  }

  Future<PregnancyModel> markDelivered(String id) async {
    try {
      final response = await dio.put(
        '/pregnancies/$id',
        data: {'status': 'delivered'},
      );
      return PregnancyModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(_message(e, 'Gagal menandai kelahiran'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await dio.delete('/pregnancies/$id');
    } catch (e) {
      throw Exception('Gagal menghapus data kehamilan: $e');
    }
  }

  static String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  /// Pesan validasi dari server lebih berguna daripada error Dio mentah.
  static String _message(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return fallback;
  }
}
