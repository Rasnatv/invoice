//
// import 'package:dio/dio.dart';
//
// import '../../../../../core/errors/apierrorhandler.dart';
// import '../../../../../core/network/api_constants.dart';
// import '../../../../../core/network/dioclient.dart';
// import '../../../../models/owner_models/salesman_addmodel.dart';
// import '../../../../models/owner_models/salesman_deletemodel.dart';
// import '../../../../models/owner_models/salesman_getmodel.dart';
// import '../../../../models/owner_models/salesman_updatemodel.dart';
//
//
// class SalesmanRepository {
//   static const String _salesmenUrl =
//       ApiConstants.baseUrl + ApiConstants.salesmen;
//   static const String _updateSalesmanUrl =
//       ApiConstants.baseUrl + ApiConstants.updateSalesman;
//   static const String _deleteSalesmanUrl =
//       ApiConstants.baseUrl + ApiConstants.deleteSalesman;
//
//   final Dio _dio;
//
//   SalesmanRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;
//
//   /// GET salesmen -> List<HSalesmanModel>
//   Future<List<HSalesmanModel>> getSalesmen() async {
//     try {
//       final response = await _dio.get(_salesmenUrl);
//       final body = response.data as Map<String, dynamic>;
//
//       if (body['status'] == '1') {
//         final List<dynamic> data = body['data'] ?? [];
//         return data.map((e) => HSalesmanModel.fromJson(e)).toList();
//       } else {
//         throw Exception(body['message'] ?? 'Failed to fetch salesmen');
//       }
//     } on DioException catch (e) {
//       throw Exception(await ApiErrorHandler.handleDioError(e));
//     }
//   }
//
//   /// POST salesmen -> SalesmanCreateModel
//   Future<SalesmanCreateModel> addSalesman({
//     required String name,
//     required String email,
//     required String designationId,
//     required String mobile,
//     required num salary,
//     required String joiningDate, // format: yyyy-MM-dd
//     String? password,
//     bool isActive = true,
//   }) async {
//     try {
//       final response = await _dio.post(
//         _salesmenUrl,
//         data: {
//           'name': name,
//           'email': email,
//           'designation_id': designationId,
//           'mobile': mobile,
//           'salary': salary,
//           'joining_date': joiningDate,
//           'is_active': isActive,
//           if (password != null && password.isNotEmpty) 'password': password,
//         },
//       );
//
//       final body = response.data as Map<String, dynamic>;
//
//       if (body['status'] == '1') {
//         return SalesmanCreateModel.fromJson(body['data']);
//       } else {
//         throw Exception(body['message'] ?? 'Failed to add salesman');
//       }
//     } on DioException catch (e) {
//       throw Exception(await ApiErrorHandler.handleDioError(e));
//     }
//   }
//
//   /// PUT salesmen/update -> SalesmanUpdateModel
//   Future<SalesmanUpdateModel> updateSalesman({
//     required int id,
//     required String name,
//     required String email,
//     required String designationId,
//     required String mobile,
//     required num salary,
//     required String joiningDate,
//     String? password,
//     bool? isActive,
//   }) async {
//     try {
//       final response = await _dio.put(
//         _updateSalesmanUrl,
//         data: {
//           'id': id.toString(),
//           'name': name,
//           'email': email,
//           if (password != null && password.isNotEmpty) 'password': password,
//           'designation_id': designationId,
//           'mobile': mobile,
//           'salary': salary,
//           'joining_date': joiningDate,
//           if (isActive != null) 'is_active': isActive,
//         },
//       );
//
//       final body = response.data as Map<String, dynamic>;
//
//       if (body['status'] == '1') {
//         return SalesmanUpdateModel.fromJson(body['data']);
//       } else {
//         throw Exception(body['message'] ?? 'Failed to update salesman');
//       }
//     } on DioException catch (e) {
//       throw Exception(await ApiErrorHandler.handleDioError(e));
//     }
//   }
//
//   /// DELETE salesmen/delete -> SalesmanDeleteModel
//   Future<SalesmanDeleteModel> deleteSalesman(int id) async {
//     try {
//       final response = await _dio.delete(
//         _deleteSalesmanUrl,
//         data: {'id': id},
//       );
//
//       final body = response.data as Map<String, dynamic>;
//       final result = SalesmanDeleteModel.fromJson(body);
//
//       if (result.success) {
//         return result;
//       } else {
//         throw Exception(
//           result.message.isNotEmpty
//               ? result.message
//               : 'Failed to delete salesman',
//         );
//       }
//     } on DioException catch (e) {
//       throw Exception(await ApiErrorHandler.handleDioError(e));
//     }
//   }
// }
