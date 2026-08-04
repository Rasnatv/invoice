import 'package:flutter/foundation.dart';
import 'driverdespatchbillmodel.dart';

class DespatchRepository extends ChangeNotifier {
  DespatchRepository._internal() {
    _seedDummyData();
  }

  static final DespatchRepository instance = DespatchRepository._internal();

  final List<DriverDespatchedBillModel> _bills = [];

  List<DriverDespatchedBillModel> get bills => List.unmodifiable(_bills);

  void markDelivered(String billId) {
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index == -1) return;
    _bills[index].isDelivered = true;
    _bills[index].deliveredAt = DateTime.now();
    notifyListeners();
  }

  DriverDespatchedBillModel? billById(String id) {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void _seedDummyData() {
    final now = DateTime.now();

    _bills.addAll([
      DriverDespatchedBillModel(
        id: 'bill_001',
        dsNumber: 'DS-1001',
        refNo: '1001',
        contractorName: 'Suresh Builders',
        phone: '9847012345',
        address: '12, Market Road, Kanhangad, Kerala - 671315',
        salesmanName: 'Anoop P.',
        driverName: 'Rajesh',
        grandTotal: 18500,
        despatchedAt: now.subtract(const Duration(hours: 3)),
        items: const [
          DriverBillItemModel(name: 'Cement', company: 'UltraTech', size: '50kg', boxes: '40', pieces: '1'),
          DriverBillItemModel(name: 'Steel Rod', company: 'Tata Tiscon', size: '12mm', boxes: '10', pieces: '1'),
          DriverBillItemModel(name: 'Paint', company: 'Asian Paints', size: '20L', boxes: '5', pieces: '1'),
        ],
      ),
      DriverDespatchedBillModel(
        id: 'bill_002',
        dsNumber: 'DS-1002',
        refNo: '1002',
        contractorName: 'Green Valley Constructions',
        phone: '9895567890',
        address: '45, Temple Street, Kasaragod, Kerala - 671121',
        salesmanName: 'Rahul S.',
        driverName: 'Rajesh',
        grandTotal: 9800,
        despatchedAt: now.subtract(const Duration(hours: 1)),
        items: const [
          DriverBillItemModel(name: 'Plywood', company: 'Century Ply', size: '8x4 ft', boxes: '15', pieces: '1'),
          DriverBillItemModel(name: 'Screws', company: 'Local', size: '2 inch', boxes: '20', pieces: '100'),
        ],
      ),
      DriverDespatchedBillModel(
        id: 'bill_003',
        dsNumber: 'DS-0997',
        refNo: '0997',
        contractorName: 'Malabar Homes',
        phone: '9744456712',
        address: '7, Beach Road, Bekal, Kerala - 671311',
        salesmanName: 'Anoop P.',
        driverName: 'Rajesh',
        grandTotal: 26500,
        despatchedAt: now.subtract(const Duration(days: 1, hours: 2)),
        isDelivered: true,
        deliveredAt: now.subtract(const Duration(hours: 20)),
        items: const [
          DriverBillItemModel(name: 'Cement', company: 'ACC', size: '50kg', boxes: '60', pieces: '1'),
          DriverBillItemModel(name: 'Sand', company: 'Local', size: 'Per Unit', boxes: '2', pieces: '1'),
        ],
      ),
      DriverDespatchedBillModel(
        id: 'bill_004',
        dsNumber: 'DS-1003',
        refNo: '1003',
        contractorName: 'Nair Constructions',
        phone: '9633345678',
        address: '23, Hospital Road, Kanhangad, Kerala - 671315',
        salesmanName: 'Rahul S.',
        driverName: 'Suresh Nair',
        grandTotal: 14200,
        despatchedAt: now.subtract(const Duration(minutes: 40)),
        items: const [
          DriverBillItemModel(name: 'Tiles', company: 'Kajaria', size: '2x2 ft', boxes: '30', pieces: '1'),
        ],
      ),
      DriverDespatchedBillModel(
        id: 'bill_005',
        dsNumber: 'DS-0990',
        refNo: '0990',
        contractorName: 'Coastal Builders',
        phone: '9847198765',
        address: '3, Harbour Road, Bekal, Kerala - 671311',
        salesmanName: 'Anoop P.',
        driverName: 'Suresh Nair',
        grandTotal: 32100,
        despatchedAt: now.subtract(const Duration(days: 2)),
        isDelivered: true,
        deliveredAt: now.subtract(const Duration(days: 1, hours: 18)),
        items: const [
          DriverBillItemModel(name: 'Steel Rod', company: 'JSW', size: '16mm', boxes: '25', pieces: '1'),
          DriverBillItemModel(name: 'Cement', company: 'UltraTech', size: '50kg', boxes: '80', pieces: '1'),
          DriverBillItemModel(name: 'Paint', company: 'Berger', size: '10L', boxes: '8', pieces: '1'),
        ],
      ),
    ]);
  }
}