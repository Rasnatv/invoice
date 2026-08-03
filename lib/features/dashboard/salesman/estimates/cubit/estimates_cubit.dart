
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/model/estimate_model.dart';
import '../../../../../../models/estimate_model.dart';


const kEstimateFilters = ['All', 'Pending', 'Approved', 'Rejected',];

class EstimatesState extends Equatable {
  final List<EstimateModel> all;
  final String activeFilter;
  final String query;

  const EstimatesState({this.all = const [], this.activeFilter = 'All', this.query = ''});

  List<EstimateModel> get filtered {
    var list = all;
    if (activeFilter == 'Quotation') {
      list = list.where((e) => e.billType == EstimateBillType.quotation).toList();
    } else if (activeFilter != 'All') {
      list = list.where((e) => e.status == activeFilter).toList();
    }
    if (query.trim().isNotEmpty) {
      list = list
          .where((e) => e.contractorName.toLowerCase().contains(query.toLowerCase()) ||
          e.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return list;
  }

  EstimatesState copyWith({List<EstimateModel>? all, String? activeFilter, String? query}) {
    return EstimatesState(
      all: all ?? this.all,
      activeFilter: activeFilter ?? this.activeFilter,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [all, activeFilter, query];
}

class EstimatesCubit extends Cubit<EstimatesState> {
  EstimatesCubit() : super(const EstimatesState()) {
    _loadMock();
  }

  void _loadMock() {
    emit(state.copyWith(all: [
      EstimateModel(
        id: 'Ref001-01-26',
        contractorName: 'ABC Builders',
        siteAddress: 'Trivandrum, Kerala',
        phone: '+91 98765 43210',
        salesmanName: 'Rahul Kumar',
        salesmanMobile: '+91 90000 11122',
        date: DateTime(2025, 5, 20),
        status: 'Approved',
        billType: EstimateBillType.billed,
        handlingCharge: 2000,
        items: const [
          EstimateItem(
            id: 'i1',
            name: 'Marval Satuario',
            company: 'Somany',
            size: '600x1200',
            unit: 'sqrft',
            quantity: 1000,
            mrp: 80,
            rate: 60,
          ),
          EstimateItem(
            id: 'i2',
            name: 'Sanitary Ware',
            company: 'Hindware',
            size: '-',
            unit: 'sets',
            quantity: 10,
            mrp: 4500,
            rate: 3500,
          ),
        ],
      ),
      EstimateModel(
        id: 'Ref002-01-26',
        contractorName: 'Skyline Constructions',
        siteAddress: 'Kottayam, Kerala',
        phone: '+91 87654 32109',
        salesmanName: 'Rahul Kumar',
        date: DateTime(2025, 5, 19),
        status: 'Approved',
        billType: EstimateBillType.billed,
      ),
      EstimateModel(
        id: 'Ref003-01-26',
        contractorName: 'Royal Builders',
        siteAddress: 'Ernakulam, Kerala',
        phone: '+91 76543 21098',
        salesmanName: 'Rahul Kumar',
        date: DateTime(2025, 5, 18),
        status: 'Approved',
        billType: EstimateBillType.billed,
      ),
      EstimateModel(
        id: 'Ref004-01-26',
        contractorName: 'Greenfield Developers',
        siteAddress: 'Calicut, Kerala',
        phone: '+91 65432 10987',
        salesmanName: 'Rahul Kumar',
        date: DateTime(2025, 5, 17),
        status: 'Approved',
        billType: EstimateBillType.quotation,
      ),
    ]));
  }

  void setFilter(String filter) => emit(state.copyWith(activeFilter: filter));
  void setQuery(String query) => emit(state.copyWith(query: query));

  /// Auto-generates the next estimate number. Swap this for a backend call
  /// (e.g. POST /estimates/next-number) once the API is wired up.
  String nextEstimateNumber() {
    final nums = state.all
        .map((e) => int.tryParse(e.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final next = (nums.isEmpty ? 2546 : nums.reduce((a, b) => a > b ? a : b) + 1);
    return '#$next';
  }

  void addEstimate(EstimateModel estimate) {
    emit(state.copyWith(all: [estimate, ...state.all]));
  }

  void updateEstimate(EstimateModel updated) {
    emit(state.copyWith(
      all: state.all.map((e) => e.id == updated.id ? updated : e).toList(),
    ));
  }

  /// Called from the estimate preview when the user sends a saved
  /// Quotation on to Admin for approval.
  void sendForApproval(String estimateId) {
    emit(state.copyWith(
      all: state.all.map((e) {
        if (e.id != estimateId) return e;
        return e.copyWith(billType: EstimateBillType.billed, status: 'Pending');
      }).toList(),
    ));
  }
}
