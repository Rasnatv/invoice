import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../dummymodels/dispatch_model.dart';
import '../cubit/dispatch_cubit.dart';
import '../widgets/dispatch_card.dart';
import 'despatchdetailscreensalesman.dart';

class MyDispatchBillsScreen extends StatelessWidget {
  const MyDispatchBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DispatchCubit(),
      child: const _DispatchView(),
    );
  }
}

class _DispatchView extends StatelessWidget {
  const _DispatchView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('My Dispatch Bills',style: AppTextStyles.h6()),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(12)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search dispatch bills...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<DispatchCubit, List<DispatchModel>>(
                builder: (context, list) {
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                    itemCount: list.length,
                    itemBuilder: (context, i) => GestureDetector(
    onTap: (){
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => SalesDepatchBillDetailScreen()
    ),
    );
    },
                    child: DispatchCard(
                      dispatch: list[i],
                    ),
                  ),

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
