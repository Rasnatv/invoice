import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/network/tokenstorage.dart';
import '../model/designationmodel.dart';

class DesignationRepository {
  static const String baseUrl =
      'https://neethu.astradevelops.in/ceramo/public/api/salesman-designations';

  final http.Client client;

  DesignationRepository({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.readToken();
    final tokenType = await TokenStorage.readTokenType() ?? 'Bearer';

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': '$tokenType $token',
    };
  }

  /// GET salesman-designations
  Future<List<DesignationModel>> getDesignations() async {
    final response = await client.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == '1') {
      final List<dynamic> data = body['data'] ?? [];
      return data.map((e) => DesignationModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch designations');
    }
  }

  /// POST salesman-designations
  /// Body: { "designations": [ { "name": "..." } ] }
  Future<DesignationModel> addDesignation(String name) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({
        'designations': [
          {'name': name}
        ]
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == '1') {
      final List<dynamic> data = body['data'] ?? [];
      if (data.isEmpty) {
        throw Exception('Designation created but no data returned');
      }
      return DesignationModel.fromJson(data.first);
    } else {
      throw Exception(body['message'] ?? 'Failed to add designation');
    }
  }

  /// POST salesman-designations/update
  /// Body: { "id": 6, "name": "..." }
  Future<DesignationModel> updateDesignation(int id, String name) async {
    final response = await client.put(
      Uri.parse('$baseUrl/update'),
      headers: await _headers(),
      body: jsonEncode({'id': id, 'name': name}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == '1') {
      return DesignationModel.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update designation');
    }
  }

  /// POST salesman-designations/delete
  /// Body: { "id": 6 }
  Future<void> deleteDesignation(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/delete'),
      headers: await _headers(),
      body: jsonEncode({'id': id}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == '1') {
      return;
    } else {
      throw Exception(body['message'] ?? 'Failed to delete designation');
    }
  }
}