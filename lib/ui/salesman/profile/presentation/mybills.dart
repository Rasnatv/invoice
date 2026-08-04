import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../estimates/presentation/estimate_details_screen.dart';
import '../../home/widgets/recent_estimate_tile.dart';
import '../newbillqubit.dart';

class MyBills extends StatelessWidget {
  const MyBills({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => billEstimatesCubit(),
      child: const _MyBillsView(),
    );
  }
}

class _MyBillsView extends StatelessWidget {
  const _MyBillsView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Bills',
          style: AppTextStyles.h6(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<billEstimatesCubit, billEstimatesState>(
          builder: (context, state) {
            final bills = state.all;

            if (bills.isEmpty) {
              return Center(
                child: Text(
                  'No Bills Found',
                  style: AppTextStyles.subtitle(),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(16),
                Responsive.h(16),
                Responsive.w(16),
                Responsive.h(20),
              ),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecentEstimateTile(
                    estimate: bills[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EstimateDetailsScreen(
                            estimate: bills[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}