import 'package:dio/dio.dart';

import '../../../../core/utils/hpk.dart';
import '../models/child_measurement_model.dart';
import '../models/child_model.dart';

class ChildRemoteDatasource {
  final Dio dio;

  ChildRemoteDatasource(this.dio);

  Future<List<ChildModel>> getChildren() async {
    try {
      final response = await dio.get('/children');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((c) => ChildModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat profil anak: ${_detail(e)}');
    }
  }

  Future<ChildModel> getChildById(String id) async {
    try {
      final response = await dio.get('/children/$id');
      return ChildModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal memuat profil anak: ${_detail(e)}');
    }
  }

  Future<ChildModel> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    try {
      final response = await dio.post(
        '/children',
        data: _body(
          name: name,
          gender: gender,
          birthDate: birthDate,
          hpht: hpht,
          hpl: hpl,
          birthWeightKg: birthWeightKg,
          birthLengthCm: birthLengthCm,
          birthHeadCircumferenceCm: birthHeadCircumferenceCm,
        ),
      );
      return ChildModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal menyimpan profil anak: ${_detail(e)}');
    }
  }

  Future<ChildModel> updateChild({
    required String id,
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    try {
      final response = await dio.put(
        '/children/$id',
        data: _body(
          name: name,
          gender: gender,
          birthDate: birthDate,
          hpht: hpht,
          hpl: hpl,
          birthWeightKg: birthWeightKg,
          birthLengthCm: birthLengthCm,
          birthHeadCircumferenceCm: birthHeadCircumferenceCm,
        ),
      );
      return ChildModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal memperbarui profil anak: ${_detail(e)}');
    }
  }

  Future<void> deleteChild(String id) async {
    try {
      await dio.delete('/children/$id');
    } catch (e) {
      throw Exception('Gagal menghapus profil anak: ${_detail(e)}');
    }
  }

  Future<List<ChildMeasurementModel>> getMeasurements(String childId) async {
    try {
      final response = await dio.get('/children/$childId/measurements');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((m) => ChildMeasurementModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat riwayat pengukuran: ${_detail(e)}');
    }
  }

  Future<ChildMeasurementModel> addMeasurement({
    required String childId,
    required DateTime measuredAt,
    double? weight,
    double? height,
    double? headCircumference,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        '/children/$childId/measurements',
        data: {
          if (weight != null) 'weight': weight,
          if (height != null) 'height': height,
          if (headCircumference != null)
            'head_circumference_cm': headCircumference,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          'measured_at': isoDate(measuredAt),
        },
      );
      return ChildMeasurementModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Gagal menyimpan pengukuran: ${_detail(e)}');
    }
  }

  Map<String, dynamic> _body({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) {
    return {
      'name': name,
      'gender': gender,
      'birth_date': isoDate(birthDate),
      if (hpht != null) 'hpht': isoDate(hpht),
      if (hpl != null) 'hpl': isoDate(hpl),
      if (birthWeightKg != null) 'birth_weight_kg': birthWeightKg,
      if (birthLengthCm != null) 'birth_length_cm': birthLengthCm,
      if (birthHeadCircumferenceCm != null)
        'birth_head_circumference_cm': birthHeadCircumferenceCm,
    };
  }

  /// Pesan validasi dari server lebih berguna daripada error Dio mentah.
  static String _detail(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return '${first.first}';
          if (first is String) return first;
        }
        if (data['message'] is String) return data['message'] as String;
      }
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
