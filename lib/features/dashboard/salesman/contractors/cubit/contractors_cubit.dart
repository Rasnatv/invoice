import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../models/contractor_model.dart';

class ContractorsCubit extends Cubit<List<ContractorModel>> {
  ContractorsCubit() : super([]) {
    emit(const [
      ContractorModel(name: 'ABC Builders', phone: '+91 98765 43210', address: 'Trivandrum, Kerala'),
      ContractorModel(name: 'Skyline Constructions', phone: '+91 87654 32109', address: 'Kottayam, Kerala'),
      ContractorModel(name: 'Royal Builders', phone: '+91 76543 21098', address: 'Ernakulam, Kerala'),
      ContractorModel(name: 'Greenfield Developers', phone: '+91 65432 10987', address: 'Calicut, Kerala'),
    ]);
  }

  void addContractor(ContractorModel contractor) {
    emit([contractor, ...state]);
  }
}
