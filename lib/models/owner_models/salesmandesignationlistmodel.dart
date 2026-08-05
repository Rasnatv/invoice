// /// Maps a single item from: GET /salesman-designations
// class DesignationModel {
//   const DesignationModel({required this.id, required this.name});
//
//   final String id;
//   final String name;
//
//   factory DesignationModel.fromJson(Map<String, dynamic> json) {
//     return DesignationModel(
//       id: json['id']?.toString() ?? '',
//       name: (json['name'] ?? '').toString().trim(),
//     );
//   }
//
//   DesignationModel copyWith({String? id, String? name}) {
//     return DesignationModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//     );
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) || other is DesignationModel && other.id == id;
//
//   @override
//   int get hashCode => id.hashCode;
//
//   @override
//   String toString() => name;
// }
//
// /// GET /salesman-designations — the list lives at data.list
// class DesignationListResponseModel {
//   const DesignationListResponseModel({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   final String status;
//   final String message;
//   final List<DesignationModel> data;
//
//   factory DesignationListResponseModel.fromJson(Map<String, dynamic> json) {
//     final dataMap = json['data'] as Map<String, dynamic>? ?? const {};
//     final list = dataMap['list'] as List<dynamic>? ?? const [];
//     return DesignationListResponseModel(
//       status: json['status']?.toString() ?? '0',
//       message: json['message']?.toString() ?? '',
//       data: list
//           .map((e) => DesignationModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// /// POST /salesman-designations/create — body is just { "name": "..." }
// class DesignationAddRequestModel {
//   const DesignationAddRequestModel({required this.name});
//
//   final String name;
//
//   Map<String, dynamic> toJson() => {'name': name};
// }
//
// /// POST /salesman-designations/update
// class DesignationUpdateRequestModel {
//   const DesignationUpdateRequestModel({required this.id, required this.name});
//
//   final String id;
//   final String name;
//
//   Map<String, dynamic> toJson() => {'id': id, 'name': name};
// }
//
// /// POST /salesman-designations/delete
// class DesignationDeleteRequestModel {
//   const DesignationDeleteRequestModel(this.id);
//
//   final String id;
//
//   Map<String, dynamic> toJson() => {'id': id};
// }