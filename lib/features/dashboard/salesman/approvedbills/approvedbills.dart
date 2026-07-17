import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../contractors/estimates/cubit/estimates_cubit.dart';
import '../home/widgets/recent_estimate_tile.dart';
import 'approved detailpage.dart';


class ApprovedBills extends StatelessWidget {
  const ApprovedBills({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstimatesCubit(),
      child: const _MyEstimatesView(),
    );
  }
}

class _MyEstimatesView extends StatelessWidget {
  const _MyEstimatesView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('Approved Bills',style: AppTextStyles.h6(),),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
              child: TextField(
                onChanged: (v) => context.read<EstimatesCubit>().setQuery(v),
                decoration: const InputDecoration(
                  hintText: 'Search estimates...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: BlocBuilder<EstimatesCubit, EstimatesState>(
                builder: (context, state) {
                  final list = state.filtered;
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No estimates found', style: AppTextStyles.subtitle()),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                    itemCount: list.length,
                    itemBuilder: (context, i) => RecentEstimateTile(
                      estimate: list[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ApprovedDetailsScreen(estimate: list[i])),
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
