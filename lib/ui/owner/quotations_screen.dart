import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/models/owner_models/owner_viewquotationmodel.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/quotation_detail_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/ownerviewquatation/owner_viewquotation_bloc.dart';
import '../../bloc/ownerbloc/ownerviewquatation/owner_viewquotation_event.dart';
import '../../bloc/ownerbloc/ownerviewquatation/owner_viewquotations_state.dart';
import '../../widgets/owner_estimateshimmer.dart';

/// Status colours (same palette as the Estimates screen).
Color quotationStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return AppColors.success;
    case 'submitted':
    case 'pending':
    case 'sent':
      return const Color(0xFFF59E0B);
    case 'rejected':
    case 'cancelled':
      return const Color(0xFFDC2626);
    case 'draft':
      return Colors.blueGrey;
    default:
      return AppColors.primary;
  }
}

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
  //
  // Awaits the detail screen's result: the detail screen returns `true`
  // via PopScope whenever an edit/approve/cancel actually succeeded, so
  // we know to refresh this list. Returning without any change (plain
  // back navigation) returns `false`/null and skips the refresh.
  Future<void> _openQuotationDetails(OwnerviewQuotationModel q) async {
    // Captured before the await - reading it off `context` afterwards is
    // unsafe if this element gets deactivated while the detail screen is open.
    final bloc = context.read<QuotationBloc>();

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationDetailsScreen(
          quotationId: q.id,
        ),
      ),
    );

    if (changed == true && mounted) {
      bloc.add(const RefreshQuotationsEvent());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates) ----------
        appBar: AppBar(
          title: Text('Quotations', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocBuilder<QuotationBloc, QuotationState>(
            builder: (context, state) {
              // ---- loading skeleton ----
              if (state is QuotationLoading || state is QuotationInitial) {
                return Padding(
                  padding: EdgeInsets.only(top: Responsive.h(14)),
                  child: ShimmerListPlaceholder(
                    itemCount: 6,
                    padding: listPadding,
                    separatorHeight: Responsive.h(10),
                    itemBuilder: (context, i) =>
                    const _QuotationCardSkeleton(),
                  ),
                );
              }

              // ---- error ----
              if (state is QuotationError) {
                return _ErrorView(
                  message: state.message ?? 'Failed to load quotations.',
                  onRetry: () => context
                      .read<QuotationBloc>()
                      .add(const FetchQuotationsEvent()),
                );
              }

              final loaded = state as QuotationLoaded;
              final filteredQuotations = loaded.visibleQuotations;
              // Only auto-load-more when there's no active search filter -
              // pagination fetches raw pages from the API, which won't line up
              // with a client-side filtered/searched view.
              final canLoadMore = loaded.searchQuery.trim().isEmpty;

              return Column(
                children: [
                  // Search
                  Padding(
                    padding: EdgeInsets.fromLTRB(Responsive.w(20),
                        Responsive.h(14), Responsive.w(20), 0),
                    child: _SearchField(
                      controller: _searchCtrl,
                      hint: 'Search by customer, ID or salesman',
                      onChanged: (value) => context
                          .read<QuotationBloc>()
                          .add(SearchQuotationsEvent(value)),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // My Quotations / Salesman Quotations toggle
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                    child: _QuotationFilterToggle(
                      value: loaded.filter,
                      onChanged: (value) => context
                          .read<QuotationBloc>()
                          .add(FilterQuotationsEvent(value)),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // Quotation List
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (canLoadMore &&
                            notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 200) {
                          context
                              .read<QuotationBloc>()
                              .add(const LoadMoreQuotationsEvent());
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<QuotationBloc>()
                              .add(const RefreshQuotationsEvent());
                        },
                        child: filteredQuotations.isEmpty
                            ? LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                                physics:
                                const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          size: 44,
                                          color: AppColors.textSecondary
                                              .withOpacity(0.4),
                                        ),
                                        SizedBox(height: Responsive.h(10)),
                                        Text(
                                          'No quotations found',
                                          style: AppTextStyles.subtitle(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        )
                            : ListView.separated(
                          physics:
                          const AlwaysScrollableScrollPhysics(),
                          padding: listPadding,
                          itemCount: filteredQuotations.length +
                              (canLoadMore && loaded.isLoadingMore
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, __) =>
                              SizedBox(height: Responsive.h(10)),
                          itemBuilder: (context, index) {
                            if (index >= filteredQuotations.length) {
                              return const Padding(
                                padding:
                                EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            final q = filteredQuotations[index];
                            return _QuotationCard(
                              key: ValueKey(q.id),
                              quotation: q,
                              currency: currency,
                              showSalesman: loaded.filter ==
                                  QuotationFilterType.salesman,
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
      ),
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        prefixIcon: Icon(Icons.search_rounded,
            size: 20, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(13)),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(11),
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =====================================================================
// FILTER TOGGLE
// =====================================================================

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: Responsive.h(9)),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(11.5),
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ERROR / SKELETON
// =====================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotationCardSkeleton extends StatelessWidget {
  const _QuotationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: Responsive.w(12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// QUOTATION CARD
// =====================================================================

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    super.key,
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
    final statusColor = quotationStatusColor(quotation.status);

    final hasCreator = quotation.createdByName.isNotEmpty;
    // Avoid showing the same name twice when salesman == creator.
    final showSalesmanRow = showSalesman &&
        quotation.salesmanName.isNotEmpty &&
        quotation.salesmanName != quotation.createdByName;

    return _ListCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: icon, number + customer, status ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.assignment_outlined),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotation.quotationNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      quotation.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(
                label: quotation.status.isEmpty ? '-' : quotation.status,
                color: statusColor,
              ),
            ],
          ),

          // ---- phone / created by / salesman ----
          if (quotation.customerPhone.isNotEmpty) ...[
            SizedBox(height: Responsive.h(10)),
            _InfoRow(
              icon: Icons.phone_outlined,
              text: quotation.customerPhone,
            ),
          ],
          if (hasCreator) ...[
            SizedBox(height: Responsive.h(6)),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              text: 'Created by: ${quotation.createdByName}',
              color: AppColors.primary,
            ),
          ],
          if (showSalesmanRow) ...[
            SizedBox(height: Responsive.h(6)),
            _InfoRow(
              icon: Icons.badge_outlined,
              color: AppColors.primary,
              text: 'Salesman: ${quotation.salesmanName}',
            ),
          ],

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: date, items, total ----
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  '${quotation.date}  •  ${quotation.totalItemsValue} items',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                  AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              // FittedBox shrinks very large totals instead of overflowing.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    currency.format(quotation.grandTotalValue),
                    maxLines: 1,
                    style: AppTextStyles.amount(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}