import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import 'owner_fieldstaffactive_event.dart';
import 'owner_fieldstaffactive_state.dart';

class FieldStaffActiveBloc
    extends Bloc<FieldStaffActiveEvent, FieldStaffActiveState> {
  final OwnerReportsProvider _provider;

  FieldStaffActiveBloc({OwnerReportsProvider? provider})
      : _provider = provider ?? OwnerReportsProvider(),
        super(const FieldStaffActiveInitial()) {
    on<FetchActiveFieldStaff>(_onFetch);
  }

  Future<void> _onFetch(
      FetchActiveFieldStaff event,
      Emitter<FieldStaffActiveState> emit,
      ) async {
    emit(const FieldStaffActiveLoading());
    final result = await _provider.getActiveFieldStaff();
    if (result.success) {
      emit(FieldStaffActiveLoaded(result.fieldStaff));
    } else {
      emit(FieldStaffActiveError(
        result.errorMessage ?? 'Failed to load field staff.',
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }
}