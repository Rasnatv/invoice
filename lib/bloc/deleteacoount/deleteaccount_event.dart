import 'package:equatable/equatable.dart';

abstract class DeleteAccountEvent extends Equatable {
  const DeleteAccountEvent();

  @override
  List<Object?> get props => [];
}

class DeleteAccountSubmitted extends DeleteAccountEvent {
  final String password;
  const DeleteAccountSubmitted(this.password);

  @override
  List<Object?> get props => [password];
}