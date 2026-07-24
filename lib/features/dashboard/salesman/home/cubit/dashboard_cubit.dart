
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../models/estimate_model.dart';


enum DashboardStatus { loading, loaded }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final String salesmanName;
  final int totalEstimates;
  final int approved;
  final int pending;
  final int dispatchBills;
  final double totalEarningsThisMonth;
  final List<EstimateModel> recentEstimates;
  final List<MonthlySale> monthlySales;

  const DashboardState({
    this.status = DashboardStatus.loading,
    this.salesmanName = '',
    this.totalEstimates = 0,
    this.approved = 0,
    this.pending = 0,
    this.dispatchBills = 0,
    this.totalEarningsThisMonth = 0,
    this.recentEstimates = const [],
    this.monthlySales = const [],
  });

  DashboardState copyWith({
    DashboardStatus? status,
    String? salesmanName,
    int? totalEstimates,
    int? approved,
    int? pending,
    int? dispatchBills,
    double? totalEarningsThisMonth,
    List<EstimateModel>? recentEstimates,
    List<MonthlySale>? monthlySales,
  }) {
    return DashboardState(
      status: status ?? this.status,
      salesmanName: salesmanName ?? this.salesmanName,
      totalEstimates: totalEstimates ?? this.totalEstimates,
      approved: approved ?? this.approved,
      pending: pending ?? this.pending,
      dispatchBills: dispatchBills ?? this.dispatchBills,
      totalEarningsThisMonth: totalEarningsThisMonth ?? this.totalEarningsThisMonth,
      recentEstimates: recentEstimates ?? this.recentEstimates,
      monthlySales: monthlySales ?? this.monthlySales,
    );
  }

  @override
  List<Object?> get props => [
    status,
    salesmanName,
    totalEstimates,
    approved,
    pending,
    dispatchBills,
    totalEarningsThisMonth,
    recentEstimates,
    monthlySales,
  ];
}

/// Loads the Salesman Dashboard's home summary. Backed by mock data here —
/// swap `_fetchMock` for a repository call when wiring a real API.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await Future.delayed(const Duration(milliseconds: 400));
    emit(state.copyWith(
      status: DashboardStatus.loaded,
      salesmanName: 'Rahul Kumar',
      totalEstimates: 24,
      approved: 18,
      pending: 6,
      dispatchBills: 8,
      totalEarningsThisMonth: 645000,
      // Replace with a real "last 6 months revenue" API call.
      monthlySales: const [
        MonthlySale(monthLabel: 'Feb', amount: 320000),
        MonthlySale(monthLabel: 'Mar', amount: 410000),
        MonthlySale(monthLabel: 'Apr', amount: 380000),
        MonthlySale(monthLabel: 'May', amount: 510000),
        MonthlySale(monthLabel: 'Jun', amount: 470000),
        MonthlySale(monthLabel: 'Jul', amount: 645000),
      ],
      recentEstimates: [
        EstimateModel(
          id: 'Est.No.001',
          contractorName: 'ABC Builders',
          siteAddress: 'Trivandrum, Kerala',
          phone: '+91 98765 43210',
          date: DateTime(2025, 5, 20),
          status: 'Pending',
          billType: EstimateBillType.billed,
          items: const [
            EstimateItem(id: 'i1', name: 'Marval Satuario', company: 'Somany', quantity: 1000, mrp: 80, rate: 60),
          ],
        ),
        EstimateModel(
          id: 'Est.No.002',
          contractorName: 'Skyline Constructions',
          siteAddress: 'Kottayam, Kerala',
          phone: '+91 87654 32109',
          date: DateTime(2025, 5, 19),
          status: 'Approved',
          billType: EstimateBillType.billed,
          items: const [
            EstimateItem(id: 'i1', name: 'Wall Tiles', company: 'Kajaria', quantity: 1500, mrp: 70, rate: 60),
          ],
        ),
        EstimateModel(
          id: 'Est.No.003',
          contractorName: 'Royal Builders',
          siteAddress: 'Ernakulam, Kerala',
          phone: '+91 76543 21098',
          date: DateTime(2025, 5, 18),
          status: 'Rejected',
          billType: EstimateBillType.billed,
          items: const [
            EstimateItem(id: 'i1', name: 'Sanitary Ware', company: 'Hindware', quantity: 10, mrp: 4500, rate: 3500),
          ],
        ),
      ],
    ));
  }
}