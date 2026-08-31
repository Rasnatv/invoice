import 'package:equatable/equatable.dart';

import '../../../models/owner_models/owner_incentivesetupmodel.dart';


abstract class SalesmanIncentiveEvent extends Equatable {
  const SalesmanIncentiveEvent();
  @override
  List<Object?> get props => [];
}

/// GET /salesman-incentive-setup — loads the salesman dropdown along with
/// each salesman's current-month setup status in one call.
class LoadSalesmanIncentiveList extends SalesmanIncentiveEvent {
  const LoadSalesmanIncentiveList();
}

/// POST /salesman-incentive-setup/get — loads (or confirms there is no)
/// existing setup for one salesman + period, to prefill the setup form.
class LoadSalesmanIncentiveSetup extends SalesmanIncentiveEvent {
  final String salesmanId;
  final String year;
  final String month;

  const LoadSalesmanIncentiveSetup({
    required this.salesmanId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [salesmanId, year, month];
}

/// POST /salesman-incentive-setup/save
class SaveSalesmanIncentiveSetup extends SalesmanIncentiveEvent {
  final SalesmanIncentiveSetupSaveRequest request;
  const SaveSalesmanIncentiveSetup(this.request);
  @override
  List<Object?> get props => [request];
}

/// POST /salesman-incentive-setup/delete
class DeleteSalesmanIncentiveSetup extends SalesmanIncentiveEvent {
  final SalesmanIncentiveSetupQueryRequest request;
  const DeleteSalesmanIncentiveSetup(this.request);
  @override
  List<Object?> get props => [request];
}

/// Resets the detail/action slices, e.g. when the setup screen closes.
class ClearSalesmanIncentiveSetupDetail extends SalesmanIncentiveEvent {
  const ClearSalesmanIncentiveSetupDetail();
}