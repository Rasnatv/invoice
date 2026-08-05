// class DummyDispatchItem {
//   DummyDispatchItem({
//     required this.name,
//     required this.company,
//     required this.size,
//     required this.boxes,
//     required this.pieces,
//   });
//
//   final String name;
//   final String company;
//   final String size;
//   final String boxes;
//   final String pieces;
// }
//
// class DummyDispatchModel {
//   DummyDispatchModel({
//     required this.id,
//     required this.dsNumber,
//     required this.refNo,
//     required this.contractorName,
//     required this.phone,
//     required this.siteAddress,
//     required this.despatchedBy,
//     required this.date,
//     required this.amount,
//     required this.status,
//     required this.items,
//     this.deliveredAt,
//   });
//
//   final String id;
//   final String dsNumber;
//   final String refNo;
//   final String contractorName;
//   final String phone;
//   final String siteAddress;
//   final String despatchedBy;
//   final DateTime date;
//   final double amount;
//   final String status; // 'Delivered' | 'on progress'
//   final List<DummyDispatchItem> items;
//   final DateTime? deliveredAt;
// }
class DummyDispatchModel {
  final String id;
  final String dsNumber;
  final String refNo;
  final String contractorName;
  final String phone;
  final String siteAddress;
  final String despatchedBy;
  final DateTime date;
  final double amount;
  final String status;
  final DateTime? deliveredAt;
  final String driverName;
  final List<DummyDispatchItem> items;

  DummyDispatchModel({
    required this.id,
    required this.dsNumber,
    required this.refNo,
    required this.contractorName,
    required this.phone,
    required this.siteAddress,
    required this.despatchedBy,
    required this.date,
    required this.amount,
    required this.status,
    this.deliveredAt,
    this.driverName = '',
    required this.items,
  });
}

class DummyDispatchItem {
  final String name;
  final String company;
  final String size;
  final String boxes;
  final String pieces;

  DummyDispatchItem({
    required this.name,
    required this.company,
    required this.size,
    required this.boxes,
    required this.pieces,
  });
}