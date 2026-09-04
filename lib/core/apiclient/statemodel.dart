/// Common class to transfer data
abstract class StateModel<T> {
  const StateModel();

  factory StateModel.success(T value) = SuccessState<T>;

  factory StateModel.error(String message) = ErrorState<T>;
}

/// Transfer success data object
class SuccessState<T> extends StateModel<T> {
  final T value;

  const SuccessState(this.value) : super();
}

/// Transfer error message
class ErrorState<T> extends StateModel<T> {
  final String msg;

  const ErrorState(this.msg) : super();
}