import 'package:equatable/equatable.dart';

class ConnectivityState extends Equatable {
  final bool isOffline;
  final int reconnectCount;

  const ConnectivityState({
    required this.isOffline,
    required this.reconnectCount,
  });

  factory ConnectivityState.initial() =>
      const ConnectivityState(isOffline: false, reconnectCount: 0);

  ConnectivityState copyWith({bool? isOffline, int? reconnectCount}) {
    return ConnectivityState(
      isOffline: isOffline ?? this.isOffline,
      reconnectCount: reconnectCount ?? this.reconnectCount,
    );
  }

  @override
  List<Object?> get props => [isOffline, reconnectCount];
}