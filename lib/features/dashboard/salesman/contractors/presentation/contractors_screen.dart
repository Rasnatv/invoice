import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../models/contractor_model.dart';
import '../cubit/contractors_cubit.dart';
import '../widgets/contractor_card.dart';
import 'add_contractor_screen.dart';

class ContractorsScreen extends StatelessWidget {
  const ContractorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractorsCubit(),
      child: const _ContractorsView(),
    );
  }
}

class _ContractorsView extends StatelessWidget {
  const _ContractorsView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contractors')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final cubit = context.read<ContractorsCubit>();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: const AddContractorScreen())),
          );
        },
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(12)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search contractors...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ContractorsCubit, List<ContractorModel>>(
                builder: (context, list) {
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                    itemCount: list.length,
                    itemBuilder: (context, i) => ContractorCard(contractor: list[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
