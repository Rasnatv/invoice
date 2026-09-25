//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../Apiprovider/salesman_quotationprovider.dart';
// import '../../../models/salesmanmodels/estimatesectionproductincentive.dart';
// import 'owner_qtneditestate.dart';
// import 'owner_qtneditevent.dart';
//
//
//
// /// Bloc for the Owner Edit Quotation screen.
// ///
// /// Deliberately self-contained (doesn't reuse SalesmanEstimateBloc /
// /// SalesmanQuotationBloc) so the owner edit screen has its own
// /// independent lifecycle, per your "owner want to separate create owner
// /// quotation editscreen" — but it talks to the exact same QuotationProvider
// /// and the exact same POST /quotations/update endpoint / request models
// /// (QuotationUpdateRequest / QuotationUpdateItemRequest) already shared
// /// with the salesman flow, so nothing on the API side changes.
// class OwnerQuotationEditBloc
//     extends Bloc<OwnerQuotationEditEvent, OwnerQuotationEditState> {
//   final QuotationProvider _provider;
//
//   OwnerQuotationEditBloc({QuotationProvider? provider})
//       : _provider = provider ?? QuotationProvider(),
//         super(const OwnerQuotationEditState()) {
//     on<OwnerEditActiveProductsRequested>(_onActiveProductsRequested);
//     on<OwnerEditProductIncentiveRequested>(_onProductIncentiveRequested);
//     on<OwnerEditProductIncentiveCleared>(_onProductIncentiveCleared);
//     on<OwnerQuotationUpdateSubmitted>(_onUpdateSubmitted);
//     on<OwnerQuotationUpdateResultConsumed>(_onUpdateResultConsumed);
//   }
//
//   Future<void> _onActiveProductsRequested(
//       OwnerEditActiveProductsRequested event,
//       Emitter<OwnerQuotationEditState> emit,
//       ) async {
//     emit(state.copyWith(
//       productsStatus: OwnerEditLoadStatus.loading,
//       clearProductsError: true,
//     ));
//     final result = await _provider.getActiveProducts();
//     if (result.success) {
//       emit(state.copyWith(
//         productsStatus: OwnerEditLoadStatus.success,
//         products: result.list,
//       ));
//     } else {
//       emit(state.copyWith(
//         productsStatus: OwnerEditLoadStatus.failure,
//         productsError: result.errorMessage,
//       ));
//     }
//   }
//
//   Future<void> _onProductIncentiveRequested(
//       OwnerEditProductIncentiveRequested event,
//       Emitter<OwnerQuotationEditState> emit,
//       ) async {
//     emit(state.copyWith(
//       incentiveStatus: OwnerEditLoadStatus.loading,
//       clearIncentiveError: true,
//     ));
//     final result = await _provider.getProductIncentive(ProductIncentiveRequest(
//       productId: event.productId,
//       quantity: event.quantity,
//       rate: event.rate,
//     ));
//     if (result.success) {
//       emit(state.copyWith(
//         incentiveStatus: OwnerEditLoadStatus.success,
//         incentive: result.incentive,
//       ));
//     } else {
//       emit(state.copyWith(
//         incentiveStatus: OwnerEditLoadStatus.failure,
//         incentiveError: result.errorMessage,
//       ));
//     }
//   }
//
//   void _onProductIncentiveCleared(
//       OwnerEditProductIncentiveCleared event,
//       Emitter<OwnerQuotationEditState> emit,
//       ) {
//     emit(state.copyWith(
//       incentiveStatus: OwnerEditLoadStatus.initial,
//       clearIncentive: true,
//     ));
//   }
//
//   Future<void> _onUpdateSubmitted(
//       OwnerQuotationUpdateSubmitted event,
//       Emitter<OwnerQuotationEditState> emit,
//       ) async {
//     emit(state.copyWith(
//       updateStatus: OwnerQuotationUpdateStatus.submitting,
//       clearUpdateMessage: true,
//       clearUpdateError: true,
//     ));
//     final result = await _provider.updateQuotation(event.request);
//     if (result.success) {
//       emit(state.copyWith(
//         updateStatus: OwnerQuotationUpdateStatus.success,
//         updateMessage: result.message,
//       ));
//     } else {
//       emit(state.copyWith(
//         updateStatus: OwnerQuotationUpdateStatus.failure,
//         updateError: result.message,
//       ));
//     }
//   }
//
//   void _onUpdateResultConsumed(
//       OwnerQuotationUpdateResultConsumed event,
//       Emitter<OwnerQuotationEditState> emit,
//       ) {
//     emit(state.copyWith(
//       updateStatus: OwnerQuotationUpdateStatus.idle,
//       clearUpdateMessage: true,
//       clearUpdateError: true,
//     ));
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';
import '../../../models/salesmanmodels/estimatesectionproductincentive.dart';
import 'owner_qtneditestate.dart';
import 'owner_qtneditevent.dart';

/// Bloc for the Owner Edit Quotation screen.
///
/// Deliberately self-contained (doesn't reuse SalesmanEstimateBloc /
/// SalesmanQuotationBloc) so the owner edit screen has its own
/// independent lifecycle, per your "owner want to separate create owner
/// quotation editscreen" — but it talks to the exact same QuotationProvider
/// and the exact same POST /quotations/update endpoint / request models
/// (QuotationUpdateRequest / QuotationUpdateItemRequest) already shared
/// with the salesman flow, so nothing on the API side changes.
class OwnerQuotationEditBloc
    extends Bloc<OwnerQuotationEditEvent, OwnerQuotationEditState> {
  final QuotationProvider _provider;

  OwnerQuotationEditBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const OwnerQuotationEditState()) {
    on<OwnerEditActiveProductsRequested>(_onActiveProductsRequested);
    on<OwnerEditProductIncentiveRequested>(_onProductIncentiveRequested);
    on<OwnerEditProductIncentiveCleared>(_onProductIncentiveCleared);
    on<OwnerQuotationUpdateSubmitted>(_onUpdateSubmitted);
    on<OwnerQuotationUpdateResultConsumed>(_onUpdateResultConsumed);
    on<OwnerQuotationItemUpdateSubmitted>(_onItemUpdateSubmitted);
    on<OwnerQuotationItemUpdateResultConsumed>(_onItemUpdateResultConsumed);
  }

  Future<void> _onActiveProductsRequested(
      OwnerEditActiveProductsRequested event,
      Emitter<OwnerQuotationEditState> emit,
      ) async {
    emit(state.copyWith(
      productsStatus: OwnerEditLoadStatus.loading,
      clearProductsError: true,
    ));
    final result = await _provider.getActiveProducts();
    if (result.success) {
      emit(state.copyWith(
        productsStatus: OwnerEditLoadStatus.success,
        products: result.list,
      ));
    } else {
      emit(state.copyWith(
        productsStatus: OwnerEditLoadStatus.failure,
        productsError: result.errorMessage,
      ));
    }
  }

  Future<void> _onProductIncentiveRequested(
      OwnerEditProductIncentiveRequested event,
      Emitter<OwnerQuotationEditState> emit,
      ) async {
    emit(state.copyWith(
      incentiveStatus: OwnerEditLoadStatus.loading,
      clearIncentiveError: true,
    ));
    final result = await _provider.getProductIncentive(ProductIncentiveRequest(
      productId: event.productId,
      quantity: event.quantity,
      rate: event.rate,
    ));
    if (result.success) {
      emit(state.copyWith(
        incentiveStatus: OwnerEditLoadStatus.success,
        incentive: result.incentive,
      ));
    } else {
      emit(state.copyWith(
        incentiveStatus: OwnerEditLoadStatus.failure,
        incentiveError: result.errorMessage,
      ));
    }
  }

  void _onProductIncentiveCleared(
      OwnerEditProductIncentiveCleared event,
      Emitter<OwnerQuotationEditState> emit,
      ) {
    emit(state.copyWith(
      incentiveStatus: OwnerEditLoadStatus.initial,
      clearIncentive: true,
    ));
  }

  Future<void> _onUpdateSubmitted(
      OwnerQuotationUpdateSubmitted event,
      Emitter<OwnerQuotationEditState> emit,
      ) async {
    emit(state.copyWith(
      updateStatus: OwnerQuotationUpdateStatus.submitting,
      clearUpdateMessage: true,
      clearUpdateError: true,
    ));
    final result = await _provider.updateQuotation(event.request);
    if (result.success) {
      emit(state.copyWith(
        updateStatus: OwnerQuotationUpdateStatus.success,
        updateMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        updateStatus: OwnerQuotationUpdateStatus.failure,
        updateError: result.message,
      ));
    }
  }

  void _onUpdateResultConsumed(
      OwnerQuotationUpdateResultConsumed event,
      Emitter<OwnerQuotationEditState> emit,
      ) {
    emit(state.copyWith(
      updateStatus: OwnerQuotationUpdateStatus.idle,
      clearUpdateMessage: true,
      clearUpdateError: true,
    ));
  }

  /// PUT /quotations/update-item — persists a single existing line item
  /// (quantity/rate/box_quantity/piece_quantity) without touching the rest
  /// of the quotation. Kept as its own submitting/success/failure status so
  /// the screen can react to it independently of the whole-quotation save.
  Future<void> _onItemUpdateSubmitted(
      OwnerQuotationItemUpdateSubmitted event,
      Emitter<OwnerQuotationEditState> emit,
      ) async {
    emit(state.copyWith(
      itemUpdateStatus: OwnerItemUpdateStatus.submitting,
      clearItemUpdateMessage: true,
      clearItemUpdateError: true,
    ));
    final result = await _provider.updateQuotationItem(QuotationItemUpdateRequest(
      quotationId: event.quotationId,
      quotationItemId: event.quotationItemId,
      quantity: event.quantity,
      rate: event.rate,
      boxQuantity: event.boxQuantity,
      pieceQuantity: event.pieceQuantity,
    ));
    if (result.success) {
      emit(state.copyWith(
        itemUpdateStatus: OwnerItemUpdateStatus.success,
        itemUpdateMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        itemUpdateStatus: OwnerItemUpdateStatus.failure,
        itemUpdateError: result.message,
      ));
    }
  }

  void _onItemUpdateResultConsumed(
      OwnerQuotationItemUpdateResultConsumed event,
      Emitter<OwnerQuotationEditState> emit,
      ) {
    emit(state.copyWith(
      itemUpdateStatus: OwnerItemUpdateStatus.idle,
      clearItemUpdateMessage: true,
      clearItemUpdateError: true,
    ));
  }
}
