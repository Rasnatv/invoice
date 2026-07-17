
import 'package:equatable/equatable.dart';

/// Whether an estimate has only been drafted for the customer (Quotation)
/// or has been finalised and sent to Admin for approval (Billed).
enum EstimateBillType { quotation, billed }

extension EstimateBillTypeX on EstimateBillType {
  String get label => this == EstimateBillType.billed ? 'Billed' : 'Quotation';
}

/// A single line item on the estimate/bill.
/// Mirrors the paper format: Item | Company | Size | Unit | Quantity | MRP | Rate | Amount
class EstimateItem extends Equatable {
  final String id;
  final String name;
  final String company;
  final String size;
  final String unit;
  final double quantity;
  final double mrp;
  final double rate;

  const EstimateItem({
    required this.id,
    required this.name,
    this.company = '',
    this.size = '',
    this.unit = 'sqrft',
    this.quantity = 0,
    this.mrp = 0,
    this.rate = 0,
  });

  /// Sale amount for this line = quantity * rate
  double get amount => quantity * rate;

  /// MRP-based value for this line, used for the "MRP Total" reference row
  double get mrpValue => quantity * mrp;

  /// Friendly quantity label e.g. "1000 sqrft"
  String get quantityLabel =>
      '${quantity % 1 == 0 ? quantity.toInt() : quantity} $unit';

  EstimateItem copyWith({
    String? name,
    String? company,
    String? size,
    String? unit,
    double? quantity,
    double? mrp,
    double? rate,
  }) {
    return EstimateItem(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      size: size ?? this.size,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      mrp: mrp ?? this.mrp,
      rate: rate ?? this.rate,
    );
  }

  @override
  List<Object?> get props => [id, name, company, size, unit, quantity, mrp, rate];
}
class EstimateModel extends Equatable {
  final String id;
  final String contractorName;
  final String siteAddress;
  final String phone;
  final String salesmanName;
  final String salesmanMobile;
  final DateTime date;
  final List<EstimateItem> items;
  final double handlingCharge;
  final EstimateBillType billType;

  /// Draft / Pending / Approved / Rejected / Dispatched
  final String status;

  // ---------------- Owner Approval ----------------

  final String? approvedBy;

  final DateTime? approvedAt;

  final String? rejectionReason;

  final String? ownerName;

  const EstimateModel({
    required this.id,
    required this.contractorName,
    this.siteAddress = '',
    this.phone = '',
    this.salesmanName = '',
    this.salesmanMobile = '',
    required this.date,
    this.items = const [],
    this.handlingCharge = 0,
    this.billType = EstimateBillType.quotation,
    this.status = 'Draft',

    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.ownerName,
  });

  double get totalQuantity =>
      items.fold(0.0, (sum, item) => sum + item.quantity);

  double get mrpTotal =>
      items.fold(0.0, (sum, item) => sum + item.mrpValue);

  double get itemsTotal =>
      items.fold(0.0, (sum, item) => sum + item.amount);

  double get totalAmount => itemsTotal + handlingCharge;

  /// Total incentive for this estimate
  double get incentiveTotal =>
      items.fold(0.0, (sum, item) => sum + 150);

  EstimateModel copyWith({
    String? id,
    String? contractorName,
    String? siteAddress,
    String? phone,
    String? salesmanName,
    String? salesmanMobile,
    DateTime? date,
    List<EstimateItem>? items,
    double? handlingCharge,
    EstimateBillType? billType,
    String? status,

    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    String? ownerName,
  }) {
    return EstimateModel(
      id: id ?? this.id,
      contractorName: contractorName ?? this.contractorName,
      siteAddress: siteAddress ?? this.siteAddress,
      phone: phone ?? this.phone,
      salesmanName: salesmanName ?? this.salesmanName,
      salesmanMobile: salesmanMobile ?? this.salesmanMobile,
      date: date ?? this.date,
      items: items ?? this.items,
      handlingCharge: handlingCharge ?? this.handlingCharge,
      billType: billType ?? this.billType,
      status: status ?? this.status,

      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    contractorName,
    siteAddress,
    phone,
    salesmanName,
    salesmanMobile,
    date,
    items,
    handlingCharge,
    billType,
    status,
    approvedBy,
    approvedAt,
    rejectionReason,
    ownerName,
  ];
}

/// One point on the "Monthly Sales" chart on the dashboard home screen.
class MonthlySale extends Equatable {
  final String monthLabel; // e.g. "Jan"
  final double amount;

  const MonthlySale({required this.monthLabel, required this.amount});

  @override
  List<Object?> get props => [monthLabel, amount];
}
