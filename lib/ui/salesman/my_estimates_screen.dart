
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/salesmanowner_estimatelistbloc.dart';
import '../../bloc/salemanbloc/salesmanowner_estimatelistevent.dart';
import '../../bloc/salemanbloc/salesmanownerestimatestate.dart';
import '../../widgets/estimate_card.dart';
// TODO: point this at wherever SalesmanEstimateDetailsScreen actually lives
// in your tree (the file you pasted with `class SalesmanEstimateDetailsScreen
// extends StatefulWidget`). The old 'estimates/presentation/estimate_details_screen.dart'
// import was the leftover dummy screen and doesn't exist/match anymore.
import 'estimatedetailscreen_forsalesman.dart';

class MyEstimatesScreen extends StatelessWidget {
  const MyEstimatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstimatesBloc()..add(const EstimatesLoadRequested()),
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
        title: Text('My Estimates', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<EstimatesBloc>();
            bloc.add(const EstimatesRefreshRequested());
            await bloc.stream.firstWhere((s) => s.status != EstimatesStatus.loading);
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
                child: TextField(
                  onChanged: (v) =>
                      context.read<EstimatesBloc>().add(EstimatesSearchQueryChanged(v)),
                  decoration: const InputDecoration(
                    hintText: 'Search estimates...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(12)),

              // Status tab bar - built entirely from whatever statuses the
              // API actually returned. If the data has 2 statuses you get
              // "All" + 2 tabs, if it has 5 you get "All" + 5 tabs.
              BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                buildWhen: (p, c) => p.filters != c.filters || p.activeFilter != c.activeFilter,
                builder: (context, state) {
                  if (state.filters.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                      itemCount: state.filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final filter = state.filters[i];
                        final selected = state.activeFilter == filter.key;
                        return ChoiceChip(
                          label: Text('${filter.label} (${filter.count})'),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: AppTextStyles.bodyBold(
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                          ),
                          onSelected: (_) =>
                              context.read<EstimatesBloc>().add(EstimatesFilterChanged(filter.key)),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: Responsive.h(12)),

              Expanded(
                child: BlocBuilder<EstimatesBloc, SalesmanownerEstimatesState>(
                  builder: (context, state) {
                    if (state.status == EstimatesStatus.loading && state.allEstimates.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == EstimatesStatus.failure && state.allEstimates.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.w(24)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage ?? 'Something went wrong.',
                                style: AppTextStyles.subtitle(),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: Responsive.h(12)),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<EstimatesBloc>()
                                    .add(const EstimatesLoadRequested()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final list = state.filteredEstimates;
                    if (list.isEmpty) {
                      return Center(
                        child: Text('No estimates found', style: AppTextStyles.subtitle()),
                      );
                    }

                    return ListView.builder(
                      padding:
                      EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                      itemCount: list.length,
                      itemBuilder: (context, i) => EstimateCard(
                        estimate: list[i],
                        // Details screen takes an id, not the whole row -
                        // pull it straight off the list item.
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SalesmanEstimateDetailsScreen(id: list[i].id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}