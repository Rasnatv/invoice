import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../home/widgets/recent_estimate_tile.dart';
import '../cubit/estimates_cubit.dart';
import '../../create_estimate_screen.dart';
import 'estimate_details_screen.dart';

class MyEstimatesScreen extends StatelessWidget {
  const MyEstimatesScreen({super.key});

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
        title:  Text('My Estimates',style: AppTextStyles.h6(),),
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
            BlocBuilder<EstimatesCubit, EstimatesState>(
              buildWhen: (p, c) => p.activeFilter != c.activeFilter,
              builder: (context, state) {
                return SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                    itemCount: kEstimateFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final filter = kEstimateFilters[i];
                      final selected = state.activeFilter == filter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: AppTextStyles.bodyBold(color: selected ? Colors.white : AppColors.textPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        onSelected: (_) => context.read<EstimatesCubit>().setFilter(filter),
                      );
                    },
                  ),
                );
              },
            ),
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
                        MaterialPageRoute(builder: (_) => EstimateDetailsScreen(estimate: list[i])),
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
