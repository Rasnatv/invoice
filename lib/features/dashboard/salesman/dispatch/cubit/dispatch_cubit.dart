import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../models/dispatch_model.dart';


/// Holds the "My Dispatch Bills" list. Mocked here; swap for a
/// repository fetch when a backend is available.
class DispatchCubit extends Cubit<List<DispatchModel>> {
  DispatchCubit() : super([]) {
    emit([
      DispatchModel(
        id: 'DB #1256',
        contractorName: 'ABC Builders',
        siteAddress: 'Trivandrum, Kerala',
        date: DateTime(2025, 5, 20),
        amount: 245000,
        status: 'Delivered',
        despatchedBy: 'Anil Kumar',
      ),
      DispatchModel(
        id: 'DB #1255',
        contractorName: 'Skyline Constructions',
        siteAddress: 'Kottayam, Kerala',
        date: DateTime(2025, 5, 18),
        amount: 186500,
        status: 'on progress',
        despatchedBy: 'Suresh Nair',
      ),
      DispatchModel(
        id: 'DB #1254',
        contractorName: 'Royal Builders',
        siteAddress: 'Ernakulam, Kerala',
        date: DateTime(2025, 5, 17),
        amount: 125000,
        status: 'Delivered',
        despatchedBy: 'Anil Kumar',
      ),
      DispatchModel(
        id: 'DB #1253',
        contractorName: 'Greenfield Developers',
        siteAddress: 'Calicut, Kerala',
        date: DateTime(2025, 5, 16),
        amount: 95000,
        status: 'Delivered',
        despatchedBy: 'Rajesh Menon',
      ),
    ]);
  }
}
