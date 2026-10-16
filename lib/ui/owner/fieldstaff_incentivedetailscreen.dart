import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
import '../../bloc/ownerbloc/fieldstaffincentivedetail/fieldstaffincentivedetail_bloc.dart';
import '../../bloc/ownerbloc/fieldstaffincentivedetail/fieldstaffincentivedetail_event.dart';
import '../../bloc/ownerbloc/fieldstaffincentivedetail/fieldstaffincentivedetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/fieldstaffincentivemodel.dart';
import '../../widgets/appsnackbar.dart';

/// Status colours (same palette as the list screen / Estimates).
Color _statusColor(String status) {
  switch (status) {
    case 'paid':
      return AppColors.success;
    case 'approved':
      return Colors.blue.shade700;
    case 'pending':
    default:
      return const Color(0xFFF59E0B);
  }
}

/// Public entry point - provide id of the incentive to view.
class IncentiveDetailScreen extends StatelessWidget {
  const IncentiveDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      IncentiveDetailBloc(provider: IncentiveProvider(), incentiveId: id)
        ..add(LoadIncentiveDetail(id)),
      child: const _IncentiveDetailView(),
    );
  }
}

class _IncentiveDetailView extends StatelessWidget {
  const _IncentiveDetailView();

  void _openMarkPaidSheet(
      BuildContext context, FieldStaffIncentiveModel incentive) {
    final bloc = context.read<IncentiveDetailBloc>();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    DateTime paymentDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(20),
                  Responsive.h(20),
                  Responsive.w(20),
                  Responsive.h(24),
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(16)),
                        Text('Mark as Paid', style: AppTextStyles.h6()),
                        SizedBox(height: Responsive.h(4)),
                        Text(
                          '₹${incentive.incentiveAmountFormatted} to ${incentive.fieldStaffName}',
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        ),
                        SizedBox(height: Responsive.h(18)),
                        TextFormField(
                          controller: referenceController,
                          style: AppTextStyles.body(),
                          decoration: _inputDecoration(
                              'Payment Reference', Icons.tag_outlined),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter a payment reference'
                              : null,
                        ),
                        SizedBox(height: Responsive.h(14)),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate: paymentDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setSheetState(() => paymentDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Payment Date',
                              labelStyle: AppTextStyles.body(
                                  color: AppColors.textHint),
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                              prefixIcon: Icon(Icons.event_outlined,
                                  color: AppColors.textSecondary, size: 20),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(14),
                                vertical: Responsive.h(14),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            child: Text(
                              _formatDate(paymentDate),
                              style: AppTextStyles.body(),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: notesController,
                          maxLines: 2,
                          style: AppTextStyles.body(),
                          decoration: _inputDecoration(
                              'Notes (optional)', Icons.notes_outlined),
                        ),
                        SizedBox(height: Responsive.h(20)),
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.h(48),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              bloc.add(MarkIncentivePaid(
                                paymentReference:
                                referenceController.text.trim(),
                                paymentDate: _formatDate(paymentDate),
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              ));
                              Navigator.pop(sheetContext);
                            },
                            child: Text(
                              'Confirm Payment',
                              style:
                              AppTextStyles.bodyBold(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(color: AppColors.textHint),
      errorStyle: AppTextStyles.caption(color: AppColors.error),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(14)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates) ----------
        appBar: AppBar(
          title: Text('Incentive Detail', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocConsumer<IncentiveDetailBloc, IncentiveDetailState>(
            listener: (context, state) {
              if (state.successMessage != null) {
                AppSnackbar.success(state.successMessage!);
                context
                    .read<IncentiveDetailBloc>()
                    .add(const ClearIncentiveDetailFeedback());
              } else if (state.errorMessage != null) {
                AppSnackbar.error(state.errorMessage!);
                context
                    .read<IncentiveDetailBloc>()
                    .add(const ClearIncentiveDetailFeedback());
              }
            },
            builder: (context, state) {
              if (state.incentive == null) {
                if (state.status == IncentiveDetailStatus.error) {
                  return _ErrorState(
                    onRetry: () => context.read<IncentiveDetailBloc>().add(
                        LoadIncentiveDetail(
                            context.read<IncentiveDetailBloc>().incentiveId)),
                  );
                }
                // Covers both `initial` (first frame, before the async load
                // handler has run) and `loading`.
                return const Center(child: CircularProgressIndicator());
              }

              final incentive = state.incentive!;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(Responsive.w(20),
                    Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                child: Column(
                  children: [
                    _AmountCard(incentive: incentive),
                    SizedBox(height: Responsive.h(12)),
                    _DetailCard(incentive: incentive),
                    if (incentive.notes.isNotEmpty) ...[
                      SizedBox(height: Responsive.h(12)),
                      _NotesBox(notes: incentive.notes),
                    ],
                    SizedBox(height: Responsive.h(20)),
                    if (incentive.status != 'paid')
                      SizedBox(
                        width: double.infinity,
                        height: Responsive.h(50),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: state.isSubmitting
                              ? null
                              : () => _openMarkPaidSheet(context, incentive),
                          child: state.isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : Text(
                            'Mark as Paid',
                            style: AppTextStyles.bodyBold(
                                color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PIECES
// =====================================================================

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.incentive});

  final FieldStaffIncentiveModel incentive;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(incentive.status);
    final icon = incentive.status == 'paid'
        ? Icons.check_circle_outline
        : incentive.status == 'approved'
        ? Icons.verified_outlined
        : Icons.hourglass_top_outlined;

    return _CardShell(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
            Icon(Icons.payments_outlined, color: AppColors.primary, size: 24),
          ),
          SizedBox(height: Responsive.h(10)),
          Text(
            '₹${incentive.incentiveAmountFormatted}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: AppColors.primary,
              fontSize: Responsive.sp(28),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: Responsive.h(2)),
          Text(
            'Incentive for site visit',
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
          SizedBox(height: Responsive.h(10)),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(12), vertical: Responsive.h(5)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: color),
                SizedBox(width: Responsive.w(6)),
                Text(
                  incentive.statusLabel,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    color: color,
                    fontSize: Responsive.sp(11.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.incentive});

  final FieldStaffIncentiveModel incentive;

  @override
  Widget build(BuildContext context) {
    final showPaidOn = incentive.status == 'paid' && incentive.paidAt.isNotEmpty;

    return _CardShell(
      child: Column(
        children: [
          _DetailRow(label: 'Field Staff', value: incentive.fieldStaffName),
          _DetailRow(
              label: 'Customer', value: incentive.siteVisit.customerName),
          _DetailRow(
              label: 'Site Address', value: incentive.siteVisit.siteAddress),
          _DetailRow(label: 'Visit Date', value: incentive.siteVisit.visitDate),
          _DetailRow(label: 'Linked Estimate', value: incentive.estimateNumber),
          _DetailRow(
            label: 'Created',
            value: incentive.createdAt,
            isLast: !showPaidOn,
          ),
          if (showPaidOn)
            _DetailRow(label: 'Paid On', value: incentive.paidAt, isLast: true),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Responsive.h(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.textPrimary,
                fontSize: Responsive.sp(12.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: amber.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTES',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: const Color(0xFF9A7115),
              fontSize: Responsive.sp(10.5),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: Responsive.h(6)),
          Text(
            notes,
            style: AppTextStyles.body(color: const Color(0xFF6B5316)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 38,
                color: AppColors.textSecondary.withOpacity(0.5)),
            SizedBox(height: Responsive.h(10)),
            Text('Could not load incentive', style: AppTextStyles.subtitle()),
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