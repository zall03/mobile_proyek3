import 'package:dio/dio.dart';

import '../../../../core/utils/hpk.dart';
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
      throw Exception('Gagal memuat profil kehamilan: ${_detail(e)}');
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
      throw Exception('Gagal memuat daftar kehamilan: ${_detail(e)}');
    }
  }

  Future<PregnancyModel> create({
    required String motherName,
    required DateTime hphtDate,
    DateTime? hplDate,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        '/pregnancies',
        data: {
          'mother_name': motherName,
          'hpht_date': isoDate(hphtDate),
          if (hplDate != null) 'hpl_date': isoDate(hplDate),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      return PregnancyModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(_detail(e, 'Gagal menyimpan profil kehamilan'));
    }
  }

  Future<PregnancyModel> update({
    required String id,
    required String motherName,
    required DateTime hphtDate,
    DateTime? hplDate,
    String? notes,
  }) async {
    try {
      final response = await dio.put(
        '/pregnancies/$id',
        data: {
          'mother_name': motherName,
          'hpht_date': isoDate(hphtDate),
          if (hplDate != null) 'hpl_date': isoDate(hplDate),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      return PregnancyModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(_detail(e, 'Gagal memperbarui profil kehamilan'));
    }
  }

  Future<void> registerBirth({
    required String id,
    required DateTime deliveryDate,
    required String babyName,
    required String gender,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'delivery_date': isoDate(deliveryDate),
        'baby_name': babyName,
        'gender': gender,
        if (birthWeightKg != null) 'birth_weight_kg': birthWeightKg,
        if (birthLengthCm != null) 'birth_length_cm': birthLengthCm,
        if (birthHeadCircumferenceCm != null)
          'birth_head_circumference_cm': birthHeadCircumferenceCm,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };
      print('=== REGISTER BIRTH REQUEST ===');
      print('POST /pregnancies/$id/delivery');
      print('Data: $data');
      print('==============================');
      await dio.post('/pregnancies/$id/delivery', data: data);
    } catch (e) {
      throw Exception(_detail(e, 'Gagal menyimpan data kelahiran'));
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
      throw Exception(_detail(e, 'Gagal menandai kelahiran'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await dio.delete('/pregnancies/$id');
    } catch (e) {
      throw Exception('Gagal menghapus data kehamilan: ${_detail(e)}');
    }
  }

  /// Pesan validasi dari server lebih berguna daripada error Dio mentah.
  static String _detail(Object error, [String? fallback]) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      
      print('=== DEBUG ERROR ===');
      print('Status: $statusCode');
      print('Response data: $data');
      print('Request path: ${error.requestOptions.path}');
      print('Request data: ${error.requestOptions.data}');
      print('==================');
      
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return '[$statusCode] ${first.first}';
          }
          if (first is String) return '[$statusCode] $first';
        }
        if (data['message'] is String) {
          return '[$statusCode] ${data['message']}';
        }
      }
      
      if (statusCode != null) {
        return '[$statusCode] ${error.message ?? "Unknown error"}';
      }
    }
    if (fallback != null) return fallback;
    return error.toString().replaceFirst('Exception: ', '');
  }
}
