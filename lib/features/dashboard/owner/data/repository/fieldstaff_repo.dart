import 'package:dio/dio.dart';

import '../../../../../core/network/dioclient.dart';
import '../model/fieldstaff_cretaemodel.dart';
import '../model/fieldstaff_deletemodel.dart';
import '../model/fieldstaff_getmodel.dart';
import '../model/fieldstaff_updatemodel.dart';

/// Pure data layer for Field Staff — no bloc/state logic, no widgets.
/// DioExceptions are left to propagate as-is so the bloc can route them
/// through ApiErrorHandler (handles 401 -> login redirect and gives
/// friendly messages for every other status code).
class NewFieldStaffRepository {
  static const String _endpoint = '/field-staff';

  final Dio _dio = DioClient.instance;

  /// GET /field-staff
  Future<List<FieldStaffModel>> fetchFieldStaffList() async {
    final response = await _dio.get(_endpoint);
    final json = response.data as Map<String, dynamic>;

    if (json['status']?.toString() == '1') {
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => FieldStaffModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message']?.toString() ?? 'Failed to load field staff');
  }

  /// POST /field-staff
  Future<FieldStaffCreateModel> createFieldStaff(
      FieldStaffCreateModel request,
      ) async {
    final response = await _dio.post(_endpoint, data: request.toJson());
    final json = response.data as Map<String, dynamic>;

    if (json['status']?.toString() == '1') {
      return FieldStaffCreateModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      );
    }
    throw Exception(json['message']?.toString() ?? 'Failed to add field staff');
  }

  /// POST /field-staff/update
  Future<FieldStaffUpdateModel> updateFieldStaff(
      FieldStaffUpdateModel request,
      ) async {
    final response = await _dio.put('$_endpoint/update', data: request.toJson());
    final json = response.data as Map<String, dynamic>;

    if (json['status']?.toString() == '1') {
      return FieldStaffUpdateModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      );
    }
    throw Exception(json['message']?.toString() ?? 'Failed to update field staff');
  }

  /// POST /field-staff/delete
  Future<void> deleteFieldStaff(FieldStaffDeleteModel request) async {
    final response = await _dio.delete('$_endpoint/delete', data: request.toJson());
    final json = response.data as Map<String, dynamic>;

    if (json['status']?.toString() != '1') {
      throw Exception(json['message']?.toString() ?? 'Failed to remove field staff');
    }
  }
}