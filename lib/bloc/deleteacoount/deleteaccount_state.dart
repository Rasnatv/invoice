import 'package:equatable/equatable.dart';

enum DeleteAccountStatus { initial, submitting, success, failure }

class DeleteAccountState extends Equatable {
  final DeleteAccountStatus status;
  final String? message;

  const DeleteAccountState({
    this.status = DeleteAccountStatus.initial,
    this.message,
  });

  bool get isSubmitting => status == DeleteAccountStatus.submitting;

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    String? message,
  }) {
    return DeleteAccountState(
      status: status ?? this.status,
      // Not falling back to the old message: every emit says explicitly
      // whether a message is present.
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}