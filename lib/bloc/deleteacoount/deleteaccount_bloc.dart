import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/delete_accountprovider.dart';
import '../../models/deleteaccountmodel.dart';
import 'deleteaccount_event.dart';
import 'deleteaccount_state.dart';


class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountProvider _provider;

  DeleteAccountBloc({DeleteAccountProvider? provider})
      : _provider = provider ?? DeleteAccountProvider(),
        super(const DeleteAccountState()) {
    on<DeleteAccountSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
      DeleteAccountSubmitted event,
      Emitter<DeleteAccountState> emit,
      ) async {
    emit(state.copyWith(status: DeleteAccountStatus.submitting));

    final result = await _provider.deleteAccount(
      DeleteAccountRequest(password: event.password),
    );

    if (result.success) {
      emit(state.copyWith(
        status: DeleteAccountStatus.success,
        message: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        message: result.errorMessage,
      ));
    }
  }
}