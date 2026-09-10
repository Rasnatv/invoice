import 'package:equatable/equatable.dart';

abstract class IncentiveDetailEvent extends Equatable {
  const IncentiveDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncentiveDetail extends IncentiveDetailEvent {
  final String id;

  const LoadIncentiveDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkIncentivePaid extends IncentiveDetailEvent {
  final String paymentReference;
  final String paymentDate; // yyyy-MM-dd
  final String? notes;

  const MarkIncentivePaid({
    required this.paymentReference,
    required this.paymentDate,
    this.notes,
  });

  @override
  List<Object?> get props => [paymentReference, paymentDate, notes];
}

class ClearIncentiveDetailFeedback extends IncentiveDetailEvent {
  const ClearIncentiveDetailFeedback();
}