import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/model/estimate_model.dart';
import '../../../../core/model/product_incentive_model.dart';
import '../../../../core/model/salesmanmodel.dart';
import '../../../../models/estimate_model.dart';


class OwnerState {
  final List<EstimateModel> estimates;
  final List<ProductIncentiveModel> products;
  final List<SalesmanModel> salesmen;
  final bool loading;

  const OwnerState({
    this.estimates = const [],
    this.products = const [],
    this.salesmen = const [],
    this.loading = false,
  });

  OwnerState copyWith({
    List<EstimateModel>? estimates,
    List<ProductIncentiveModel>? products,
    List<SalesmanModel>? salesmen,
    bool? loading,
  }) {
    return OwnerState(
      estimates: estimates ?? this.estimates,
      products: products ?? this.products,
      salesmen: salesmen ?? this.salesmen,
      loading: loading ?? this.loading,
    );
  }

  // ---------------- Derived dashboard stats ----------------
  int get totalEstimates => estimates.length;
  int get dispatchedCount => estimates.where((e) => e.status == 'Dispatched').length;
  int get quotationCount => estimates.where((e) => e.billType == EstimateBillType.quotation).length;
  int get pendingApprovalCount => estimates.where((e) => e.status == 'Pending').length;
  double get totalSalesValue => estimates.fold(0.0, (s, e) => s + 150);

  int get totalSalesmen => salesmen.length;
  int get activeSalesmenCount => salesmen.where((s) => s.status == 'Active').length;
}

class OwnerCubit extends Cubit<OwnerState> {
  OwnerCubit() : super(const OwnerState()) {
    _loadDummy();
  }

  // TODO(backend): replace this dummy seed with a real repository/API call
  // once the owner-side estimate & product-master endpoints exist. The
  // salesman app should push newly created estimates here (e.g. via a
  // shared repository) so they show up for the owner to approve.
  void _loadDummy() {
    emit(state.copyWith(estimates: _dummyEstimates, products: _dummyProducts, salesmen: _dummySalesmen));
  }

  void approveEstimate(String id, String approvedBy) {
    final updated = state.estimates.map((e) {
      if (e.id != id) return e;
      return e.copyWith(status: 'Approved',);
    }).toList();
    emit(state.copyWith(estimates: updated));
  }

  void rejectEstimate(String id, String? reason) {
    final updated = state.estimates.map((e) {
      if (e.id != id) return e;
      return e.copyWith(status: 'Rejected', );
    }).toList();
    emit(state.copyWith(estimates: updated));
  }

  void markDispatched(String id) {
    final updated = state.estimates.map((e) {
      if (e.id != id) return e;
      return e.copyWith(status: 'Dispatched');
    }).toList();
    emit(state.copyWith(estimates: updated));
  }

  void addProduct(ProductIncentiveModel product) {
    emit(state.copyWith(products: [...state.products, product]));
  }

  void updateProduct(ProductIncentiveModel product) {
    final updated = state.products.map((p) => p.id == product.id ? product : p).toList();
    emit(state.copyWith(products: updated));
  }

  void deleteProduct(String id) {
    emit(state.copyWith(products: state.products.where((p) => p.id != id).toList()));
  }

  // TODO(backend): replace with a real API call that persists the new
  // salesman and returns the created record (with a server-generated id).
  void addSalesman({required String name, required String mobile, required String email}) {
    final salesman = SalesmanModel(
      id: 'SM-${1001 + state.salesmen.length}',
      name: name,
      mobile: mobile,
      email: email,
      joinedDate: DateTime.now(), status: '',
    );
    emit(state.copyWith(salesmen: [...state.salesmen, salesman]));
  }

  void updateSalesman(SalesmanModel salesman) {
    final updated = state.salesmen.map((s) => s.id == salesman.id ? salesman : s).toList();
    emit(state.copyWith(salesmen: updated));
  }

  void toggleSalesmanStatus(String id) {
    final updated = state.salesmen.map((s) {
      if (s.id != id) return s;
      return s.copyWith(status: s.status == 'Active' ? 'Inactive' : 'Active');
    }).toList();
    emit(state.copyWith(salesmen: updated));
  }

  void deleteSalesman(String id) {
    emit(state.copyWith(salesmen: state.salesmen.where((s) => s.id != id).toList()));
  }
}

// =====================================================================
// DUMMY SEED DATA (remove once wired to a real backend)
// =====================================================================

final List<EstimateModel> _dummyEstimates = [
  EstimateModel(
    id: 'EST-1042',
    contractorName: 'Ramesh Constructions',
    siteAddress: 'Kanhangad, Kerala',
    phone: '9876543210',
    salesmanName: 'Rahul Kumar',
    salesmanMobile: '9123456780',
    date: DateTime.now().subtract(const Duration(days: 1)),
    handlingCharge: 500,
    billType: EstimateBillType.billed,
    status: 'Pending',
    items: [
      const EstimateItem(id: 'i1', name: 'Vitrified Tile 600x600', company: 'Kajaria', size: '600x600', unit: 'sqft', quantity: 420, mrp: 65, rate: 55),
      const EstimateItem(id: 'i2', name: 'PVC Pipe 4"', company: 'Supreme', size: '4 inch', unit: 'pcs', quantity: 60, mrp: 320, rate: 280),
    ],
  ),
  EstimateModel(
    id: 'EST-1041',
    contractorName: 'Suresh Builders',
    siteAddress: 'Kasaragod, Kerala',
    phone: '9876500001',
    salesmanName: 'Anoop Menon',
    salesmanMobile: '9123456781',
    date: DateTime.now().subtract(const Duration(days: 3)),
    handlingCharge: 300,
    billType: EstimateBillType.billed,
    status: 'Approved',
    items: [
      const EstimateItem(id: 'i1', name: 'Wall Tile 300x450', company: 'Somany', size: '300x450', unit: 'sqft', quantity: 610, mrp: 48, rate: 40),
    ],
  ),
  EstimateModel(
    id: 'EST-1040',
    contractorName: 'Green Valley Homes',
    siteAddress: 'Nileshwar, Kerala',
    phone: '9876500002',
    salesmanName: 'Rahul Kumar',
    salesmanMobile: '9123456780',
    date: DateTime.now().subtract(const Duration(days: 6)),
    handlingCharge: 400,
    billType: EstimateBillType.billed,
    status: 'Dispatched',
    items: [
      const EstimateItem(id: 'i1', name: 'Vitrified Tile 600x600', company: 'Kajaria', size: '600x600', unit: 'sqft', quantity: 980, mrp: 65, rate: 58),
      const EstimateItem(id: 'i2', name: 'CPVC Pipe 1"', company: 'Astral', size: '1 inch', unit: 'pcs', quantity: 40, mrp: 210, rate: 185),
    ],
  ),
  EstimateModel(
    id: 'EST-1039',
    contractorName: 'Nova Interiors',
    siteAddress: 'Bekal, Kerala',
    phone: '9876500003',
    salesmanName: 'Anoop Menon',
    salesmanMobile: '9123456781',
    date: DateTime.now().subtract(const Duration(days: 8)),
    handlingCharge: 0,
    billType: EstimateBillType.quotation,
    status: 'Pending',
    items: [
      const EstimateItem(id: 'i1', name: 'Wall Tile 300x450', company: 'Somany', size: '300x450', unit: 'sqft', quantity: 300, mrp: 48, rate: 42),
    ],
  ),
  EstimateModel(
    id: 'EST-1038',
    contractorName: 'City Square Developers',
    siteAddress: 'Kanhangad, Kerala',
    phone: '9876500004',
    salesmanName: 'Rahul Kumar',
    salesmanMobile: '9123456780',
    date: DateTime.now().subtract(const Duration(days: 12)),
    handlingCharge: 0,
    billType: EstimateBillType.quotation,
    status: 'Rejected',
    items: [
      const EstimateItem(id: 'i1', name: 'PVC Pipe 4"', company: 'Supreme', size: '4 inch', unit: 'pcs', quantity: 25, mrp: 320, rate: 260),
    ],
  ),
];

final List<ProductIncentiveModel> _dummyProducts = [
  const ProductIncentiveModel(
    id: 'p1',
    name: 'Vitrified Tile 600x600',
    company: 'Kajaria',
    mrp: 65,
    rate: 55,
    incentivePercent: 5,
    tier1AnnualTarget: 100000,
    tier1BonusPercent: 1,
    tier2AnnualTarget: 200000,
    tier2BonusPercent: 2,
  ),
  const ProductIncentiveModel(
    id: 'p2',
    name: 'Wall Tile 300x450',
    company: 'Somany',
    mrp: 48,
    rate: 40,
    incentivePercent: 4,
    tier1AnnualTarget: 100000,
    tier1BonusPercent: 1,
    tier2AnnualTarget: 200000,
    tier2BonusPercent: 1.5,
  ),
  const ProductIncentiveModel(
    id: 'p3',
    name: 'PVC Pipe 4"',
    company: 'Supreme',
    mrp: 320,
    rate: 280,
    incentivePercent: 3,
    tier1AnnualTarget: 100000,
    tier1BonusPercent: 0.5,
    tier2AnnualTarget: 200000,
    tier2BonusPercent: 1,
  ),
];

final List<SalesmanModel> _dummySalesmen = [
  SalesmanModel(
    id: 'SM-1001',
    name: 'Rahul Kumar',
    mobile: '9123456780',
    email: 'rahul.kumar@example.com',
    joinedDate: DateTime.now().subtract(const Duration(days: 240)),
    status: 'Active',
  ),
  SalesmanModel(
    id: 'SM-1002',
    name: 'Anoop Menon',
    mobile: '9123456781',
    email: 'anoop.menon@example.com',
    joinedDate: DateTime.now().subtract(const Duration(days: 120)),
    status: 'Active',
  ),
];
