// class DispatchModel {
//   final String id;
//   final String contractorName;
//   final String siteAddress;
//   final DateTime date;
//   final double amount;
//   final String status; // Delivered, In Transit
//
//   const DispatchModel({
//     required this.id,
//     required this.contractorName,
//     required this.siteAddress,
//     required this.date,
//     required this.amount,
//     required this.status,
//   });
// }
class DispatchModel {
  DispatchModel({
    required this.id,
    required this.contractorName,
    required this.siteAddress,
    required this.date,
    required this.amount,
    required this.status,
    required this.despatchedBy,
  });

  final String id;
  final String contractorName;
  final String siteAddress;
  final DateTime date;
  final double amount;
  final String status; // 'Delivered' | 'on progress'
  final String despatchedBy;

  DispatchModel copyWith({String? status}) {
    return DispatchModel(
      id: id,
      contractorName: contractorName,
      siteAddress: siteAddress,
      date: date,
      amount: amount,
      status: status ?? this.status,
      despatchedBy: despatchedBy,
    );
  }
}