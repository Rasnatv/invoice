/// Request body for POST /drivers/delete.
class DriverDeleteRequestModel {
  DriverDeleteRequestModel({required this.id});

  final int id;

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}