import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives which tab of the bottom navigation bar is active across
/// Dashboard / Estimates / Dispatch / Contractors / Profile.
class NavCubit extends Cubit<int> {
  NavCubit() : super(0);

  void changeTab(int index) => emit(index);
}
