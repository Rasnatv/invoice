enum QuotationStatus { pending, approved, rejected }

class QuotationModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final double amount;
  final DateTime date;
  final QuotationStatus status;
  final List<QuotationItem> items;
  final String? notes;

  QuotationModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
    required this.date,
    required this.status,
    required this.items,
    this.notes,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'].toString(),
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      status: QuotationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => QuotationStatus.pending,
      ),
      items: (json['items'] as List? ?? [])
          .map((e) => QuotationItem.fromJson(e))
          .toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'amount': amount,
    'date': date.toIso8601String(),
    'status': status.name,
    'items': items.map((e) => e.toJson()).toList(),
    'notes': notes,
  };

  QuotationModel copyWith({
    String? customerName,
    String? customerPhone,
    double? amount,
    QuotationStatus? status,
    List<QuotationItem>? items,
    String? notes,
  }) {
    return QuotationModel(
      id: id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      amount: amount ?? this.amount,
      date: date,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}

class QuotationItem {
  final String name;
  final int quantity;
  final double price;

  QuotationItem({required this.name, required this.quantity, required this.price});

  double get total => quantity * price;

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
    name: json['name'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'price': price};
}