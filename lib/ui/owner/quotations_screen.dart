
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/models/owner_models/owner_viewquotationmodel.dart';
import 'package:tileshop/ui/owner/quotation_detail_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/ownerviewquatation/owner_viewquotation_bloic.dart';
import '../../bloc/ownerbloc/ownerviewquatation/owner_viewquotation_event.dart';
import '../../bloc/ownerbloc/ownerviewquatation/owner_viewquotations_state.dart';

class OwnerQuotationsScreen extends StatelessWidget {
  const OwnerQuotationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuotationBloc()..add(const FetchQuotationsEvent()),
      child: const _OwnerQuotationsView(),
    );
  }
}

class _OwnerQuotationsView extends StatefulWidget {
  const _OwnerQuotationsView();

  @override
  State<_OwnerQuotationsView> createState() => _OwnerQuotationsViewState();
}

class _OwnerQuotationsViewState extends State<_OwnerQuotationsView> {
  final _searchCtrl = TextEditingController();

  // NOTE: /quotations/show expects the record's "id" (e.g. "23"), not the
  // human-readable "quotation_number" (e.g. "QOT0015-08-26"). Adjust
  // `q.id` below if OwnerviewQuotationModel names that field differently.
  void _openQuotationDetails(OwnerviewQuotationModel q) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationDetailsScreen(
          quotationId: q.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quotations', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: BlocBuilder<QuotationBloc, QuotationState>(
          builder: (context, state) {
            if (state is QuotationLoading || state is QuotationInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuotationError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(24)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                      SizedBox(height: Responsive.h(12)),
                      Text(
                        state.message ?? 'Failed to load quotations.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle(),
                      ),
                      SizedBox(height: Responsive.h(16)),
                      ElevatedButton(
                        onPressed: () => context
                            .read<QuotationBloc>()
                            .add(const FetchQuotationsEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state as QuotationLoaded;
            final filteredQuotations = loaded.visibleQuotations;
            // Only auto-load-more when there's no active search filter —
            // pagination fetches raw pages from the API, which won't line up
            // with a client-side filtered/searched view.
            final canLoadMore = loaded.searchQuery.trim().isEmpty;

            return Column(
              children: [
                // My Quotations / Salesman Quotations toggle
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(16),
                    Responsive.h(14),
                    Responsive.w(16),
                    Responsive.h(10),
                  ),
                  child: _QuotationFilterToggle(
                    value: loaded.filter,
                    onChanged: (value) =>
                        context.read<QuotationBloc>().add(FilterQuotationsEvent(value)),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(16),
                    0,
                    Responsive.w(16),
                    Responsive.h(10),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) =>
                        context.read<QuotationBloc>().add(SearchQuotationsEvent(value)),
                    decoration: const InputDecoration(
                      hintText: 'Search by customer, ID or salesman',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),

                // Quotation List
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (canLoadMore &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 200) {
                        context.read<QuotationBloc>().add(const LoadMoreQuotationsEvent());
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<QuotationBloc>().add(const RefreshQuotationsEvent());
                      },
                      child: filteredQuotations.isEmpty
                          ? ListView(
                        padding: EdgeInsets.only(top: Responsive.h(80)),
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: Responsive.h(16)),
                          Center(
                            child: Text(
                              'No quotations found',
                              style: AppTextStyles.subtitle(),
                            ),
                          ),
                        ],
                      )
                          : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          Responsive.w(16),
                          0,
                          Responsive.w(16),
                          Responsive.h(20),
                        ),
                        itemCount: filteredQuotations.length +
                            (canLoadMore && loaded.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                        itemBuilder: (context, index) {
                          if (index >= filteredQuotations.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }
                          final q = filteredQuotations[index];
                          return _QuotationCard(
                            quotation: q,
                            currency: currency,
                            showSalesman: loaded.filter == QuotationFilterType.salesman,
                            onTap: () => _openQuotationDetails(q),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuotationFilterToggle extends StatelessWidget {
  const _QuotationFilterToggle({
    required this.value,
    required this.onChanged,
  });

  final QuotationFilterType value;
  final ValueChanged<QuotationFilterType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'My Quotations',
            selected: value == QuotationFilterType.mine,
            onTap: () => onChanged(QuotationFilterType.mine),
          ),
          _ToggleOption(
            label: 'Salesman Quotations',
            selected: value == QuotationFilterType.salesman,
            onTap: () => onChanged(QuotationFilterType.salesman),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: Responsive.h(9)),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: selected
                ? AppTextStyles.bodyBold(color: Colors.white)
                : AppTextStyles.body(color: AppColors.textHint),
          ),
        ),
      ),
    );
  }
}

// Quotation Card Widget
class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.currency,
    required this.onTap,
    this.showSalesman = false,
  });

  final OwnerviewQuotationModel quotation;
  final NumberFormat currency;
  final VoidCallback onTap;
  final bool showSalesman;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quotation.customerName,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(quotation.status, style: AppTextStyles.caption()),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(4)),

            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Text(
                  quotation.quotationNumber,
                  style: AppTextStyles.caption(),
                ),
                if (showSalesman) ...[
                  SizedBox(width: Responsive.w(10)),
                  const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      quotation.salesmanName,
                      style: AppTextStyles.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
              ],
            ),

            SizedBox(height: Responsive.h(4)),

            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Text(
                  quotation.customerPhone,
                  style: AppTextStyles.caption(),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotation.date,
                      style: AppTextStyles.caption(),
                    ),
                    Text(
                      '${quotation.totalItemsValue} items',
                      style: AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  currency.format(quotation.grandTotalValue),
                  style: AppTextStyles.bodyBold(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}