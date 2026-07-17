
import 'dummy.dart';

/// TODO: replace this with an API call when backend is ready.
class DispatchDummyData {
  static List<DummyDispatchModel> bills = [
    DummyDispatchModel(
      id: 'DS #1256',
      dsNumber: 'DS-1256',
      refNo: 'REF-9021',
      contractorName: 'ABC Builders',
      phone: '9847012345',
      siteAddress: 'Trivandrum, Kerala',
      despatchedBy: 'Anil Kumar',
      date: DateTime(2025, 5, 20),
      amount: 245000,
      status: 'Delivered',
      deliveredAt: DateTime(2025, 5, 20, 16, 0),
      items: [
        DummyDispatchItem(name: 'Cement', company: 'UltraTech', size: '50kg', boxes: '20', pieces: '0'),
        DummyDispatchItem(name: 'Steel Rod', company: 'Tata', size: '12mm', boxes: '5', pieces: '0'),
      ],
    ),
    DummyDispatchModel(
      id: 'DS #1255',
      dsNumber: 'DS-1255',
      refNo: 'REF-9018',
      contractorName: 'Skyline Constructions',
      phone: '9876543210',
      siteAddress: 'Kottayam, Kerala',
      despatchedBy: 'Suresh Nair',
      date: DateTime(2025, 5, 18),
      amount: 186500,
      status: 'on progress',
      items: [
        DummyDispatchItem(name: 'Bricks', company: 'Local', size: 'Standard', boxes: '0', pieces: '2000'),
      ],
    ),
    DummyDispatchModel(
      id: 'DS #1254',
      dsNumber: 'DS-1254',
      refNo: 'REF-9010',
      contractorName: 'Royal Builders',
      phone: '9745123456',
      siteAddress: 'Ernakulam, Kerala',
      despatchedBy: 'Anil Kumar',
      date: DateTime(2025, 5, 17),
      amount: 125000,
      status: 'Delivered',
      deliveredAt: DateTime(2025, 5, 17, 15, 45),
      items: [
        DummyDispatchItem(name: 'Paint', company: 'Asian Paints', size: '20L', boxes: '10', pieces: '0'),
      ],
    ),
    DummyDispatchModel(
      id: 'DS #1253',
      dsNumber: 'DS-1253',
      refNo: 'REF-9004',
      contractorName: 'Greenfield Developers',
      phone: '9995567890',
      siteAddress: 'Calicut, Kerala',
      despatchedBy: 'Rajesh Menon',
      date: DateTime(2025, 5, 16),
      amount: 95000,
      status: 'Delivered',
      deliveredAt: DateTime(2025, 5, 16, 12, 30),
      items: [
        DummyDispatchItem(name: 'Tiles', company: 'Kajaria', size: '2x2 ft', boxes: '30', pieces: '0'),
      ],
    ),
  ];

  static DummyDispatchModel? billById(String id) {
    try {
      return bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}