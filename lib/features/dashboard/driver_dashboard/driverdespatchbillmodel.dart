/// One line item inside a despatched bill (mirrors the Despatch Sheet's
/// item row: name / company / size / boxes / pieces).
class DriverBillItemModel {
  final String name;
  final String company;
  final String size;
  final String boxes;
  final String pieces;

  const DriverBillItemModel({
    required this.name,
    required this.company,
    required this.size,
    required this.boxes,
    required this.pieces,
  });
}

/// A despatch bill/sheet that a salesman has despatched and assigned to a
/// driver_features. This is the model the Driver Dashboard reads from.
///
/// TODO(backend): once the despatch module has a real model/cubit, this
/// should be built from the actual EstimateModel + DespatchSheet data
/// (DS number, driver_features, delivery address, items, etc.) instead of dummy data.
class DriverDespatchedBillModel {
  final String id;
  final String dsNumber;
  final String refNo;
  final String contractorName;
  final String phone;
  final String address;
  final String salesmanName;
  final String driverName;
  final double grandTotal;
  final DateTime despatchedAt;
  final List<DriverBillItemModel> items;

  bool isDelivered;
  DateTime? deliveredAt;

  DriverDespatchedBillModel({
    required this.id,
    required this.dsNumber,
    required this.refNo,
    required this.contractorName,
    required this.phone,
    required this.address,
    required this.salesmanName,
    required this.driverName,
    required this.grandTotal,
    required this.despatchedAt,
    required this.items,
    this.isDelivered = false,
    this.deliveredAt,
  });

  int get itemCount => items.length;
}