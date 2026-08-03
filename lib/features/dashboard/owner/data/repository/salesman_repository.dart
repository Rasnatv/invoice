import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/network/tokenstorage.dart';
import '../model/salesman_addmodel.dart';
import '../model/salesman_deletemodel.dart';
import '../model/salesman_getmodel.dart';
import '../model/salesman_updatemodel.dart';

class SalesmanRepository {
  static const String baseUrl =
      'https://neethu.astradevelops.in/ceramo/public/api/salesmen';

  final http.Client client;

  SalesmanRepository({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.readToken();
    final tokenType = await TokenStorage.readTokenType() ?? 'Bearer';

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': '$tokenType $token',
    };
  }

  /// GET salesmen -> List<SalesmanModel>
  Future<List<HSalesmanModel>> getSalesmen() async {
    final response = await client.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == '1') {
      final List<dynamic> data = body['data'] ?? [];
      return data.map((e) => HSalesmanModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch salesmen');
    }
  }

  /// POST salesmen -> SalesmanCreateModel
  Future<SalesmanCreateModel> addSalesman({
    required String name,
    required String email,
    required String designationId,
    required String mobile,
    required num salary,
    required String joiningDate, // format: yyyy-MM-dd
    String? password,
  }) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'designation_id': designationId,
        'mobile': mobile,
        'salary': salary,
        'joining_date': joiningDate,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == '1') {
      return SalesmanCreateModel.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to add salesman');
    }
  }

  /// POST salesmen/update -> SalesmanUpdateModel
  Future<SalesmanUpdateModel> updateSalesman({
    required int id,
    required String name,
    required String email,
    required String designationId,
    required String mobile,
    required num salary,
    required String joiningDate,
    String? password,
    bool? isActive,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/update'),
      headers: await _headers(),
      body: jsonEncode({
        'id': id.toString(),
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        'designation_id': designationId,
        'mobile': mobile,
        'salary': salary,
        'joining_date': joiningDate,
        if (isActive != null) 'is_active': isActive,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == '1') {
      return SalesmanUpdateModel.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update salesman');
    }
  }

  /// POST salesmen/delete -> SalesmanDeleteModel
  Future<SalesmanDeleteModel> deleteSalesman(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/delete'),
      headers: await _headers(),
      body: jsonEncode({'id': id}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    final result = SalesmanDeleteModel.fromJson(body);

    if (response.statusCode == 200 && result.success) {
      return result;
    } else {
      throw Exception(body['message'] ?? 'Failed to delete salesman');
    }
  }
}