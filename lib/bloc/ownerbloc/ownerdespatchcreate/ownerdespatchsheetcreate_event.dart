import 'package:equatable/equatable.dart';
import '../../../models/owner_models/ownerdespatchsheetpreparemodel.dart';

abstract class OwnerDespatchSheetEvent extends Equatable {
  const OwnerDespatchSheetEvent();
  @override
  List<Object?> get props => [];
}

/// Loads both the quantity suggestions (POST /despatches/suggest) and the
/// active driver list (GET /drivers/active) for the given estimate.
class OwnerDespatchSheetLoadRequested extends OwnerDespatchSheetEvent {
  final String estimateId;
  const OwnerDespatchSheetLoadRequested(this.estimateId);
  @override
  List<Object?> get props => [estimateId];
}

class OwnerDespatchCreateRequested extends OwnerDespatchSheetEvent {
  final OwnerDespatchCreateRequest request;
  const OwnerDespatchCreateRequested(this.request);
  @override
  List<Object?> get props => [request];
}