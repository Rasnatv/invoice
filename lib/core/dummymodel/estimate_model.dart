//
//
// import '../../dummymodels/estimate_model.dart';
//
// /// so the rest of this codebase keeps compiling unchanged.
//
// enum EstimateBillTypenew { quotation, billed }
//
// class EstimateItemnew {
//   final String id;
//   final String name;
//   final String company;
//   final String size;
//   final String unit;
//   final double quantity;
//   final double mrp;
//   final double rate;
//
//   const EstimateItemnew({
//     required this.id,
//     required this.name,
//     required this.company,
//     required this.size,
//     required this.unit,
//     required this.quantity,
//     required this.mrp,
//     required this.rate,
//   });
//
//   double get amount => quantity * rate;
//   double get mrpValue => quantity * mrp;
//
//   // TODO(admin-config): flat dummy incentive % used everywhere an item's
//   // incentive is displayed, until per-product incentive % (see
//   // ProductIncentiveModel in product_incentive_model.dart) is looked up
//   // and stored against each item at creation time.
//   static const double _dummyIncentivePercent = 5.0;
//   double get incentivePercent => _dummyIncentivePercent;
//   double get incentiveAmount => amount * incentivePercent / 100;
// }
//
// class EstimateModelnew {
//   final String id;
//   final String contractorName;
//   final String siteAddress;
//   final String phone;
//   final String salesmanName;
//   final String salesmanMobile;
//   final DateTime date;
//   final double handlingCharge;
//   final EstimateBillType billType;
//   final String status; // Draft, Pending, Approved, Rejected, Dispatched
//   final List<EstimateItem> items;
//
//   // ---- Owner-approval additions ----
//   final String? approvedBy;
//   final DateTime? approvedAt;
//   final String? rejectionReason;
//   final String? ownername;
//
//   const EstimateModelnew({
//     required this.id,
//     required this.contractorName,
//     required this.siteAddress,
//     required this.phone,
//     required this.salesmanName,
//     required this.salesmanMobile,
//     required this.date,
//     required this.handlingCharge,
//     required this.billType,
//     required this.status,
//     required this.items,
//     this.approvedBy,
//     this.approvedAt,
//     this.rejectionReason, this.ownername,
//   });
//
//   EstimateModelnew copyWith({
//     String? status,
//     String? approvedBy,
//     DateTime? approvedAt,
//     String? rejectionReason,
//   }) {
//     return EstimateModelnew(
//       id: id,
//       contractorName: contractorName,
//       siteAddress: siteAddress,
//       phone: phone,
//       salesmanName: salesmanName,
//       salesmanMobile: salesmanMobile,
//       date: date,
//       handlingCharge: handlingCharge,
//       billType: billType,
//       status: status ?? this.status,
//       items: items,
//       approvedBy: approvedBy ?? this.approvedBy,
//       approvedAt: approvedAt ?? this.approvedAt,
//       rejectionReason: rejectionReason ?? this.rejectionReason,
//     );
//   }
//
//   double get itemsTotal => items.fold(0.0, (s, i) => s + i.amount);
//   double get mrpTotal => items.fold(0.0, (s, i) => s + i.mrpValue);
//   double get grandTotal => itemsTotal + handlingCharge;
//   double get totalQty => items.fold(0.0, (s, i) => s + i.quantity);
//   double get incentiveTotal => items.fold(0.0, (s, i) => s +150);
// }
