import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
import '../../bloc/ownerbloc/fieldstaffincentivedetail/fieldstaffincentivedetail_bloc.dart';
import '../../bloc/ownerbloc/fieldstaffincentivedetail/fieldstaffincentivedetail_event.dart';
import '../../bloc/ownerbloc/fieldstaffincentivedetail/fieldstaffincentivedetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/fieldstaffincentivemodel.dart';
import '../../widgets/appsnackbar.dart';

/// Public entry point — provide id of the incentive to view.
class IncentiveDetailScreen extends StatelessWidget {
  const IncentiveDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncentiveDetailBloc(provider: IncentiveProvider(), incentiveId: id)
        ..add(LoadIncentiveDetail(id)),
      child: const _IncentiveDetailView(),
    );
  }
}

class _IncentiveDetailView extends StatelessWidget {
  const _IncentiveDetailView();

  void _openMarkPaidSheet(BuildContext context, FieldStaffIncentiveModel incentive) {
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
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
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
                        Text(
                          'Mark as Paid',
                          style: AppTextStyles.bodyBold(color: AppColors.black)
                              .copyWith(fontSize: Responsive.sp(17)),
                        ),
                        SizedBox(height: Responsive.h(4)),
                        Text(
                          '₹${incentive.incentiveAmountFormatted} to ${incentive.fieldStaffName}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12.5)),
                        ),
                        SizedBox(height: Responsive.h(18)),
                        TextFormField(
                          controller: referenceController,
                          decoration: _inputDecoration('Payment Reference', Icons.tag_outlined),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter a payment reference' : null,
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
                            if (picked != null) setSheetState(() => paymentDate = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Payment Date',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: Icon(Icons.event_outlined, color: AppColors.textSecondary, size: 20),
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
                              style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(14)),
                        TextFormField(
                          controller: notesController,
                          maxLines: 2,
                          decoration: _inputDecoration('Notes (optional)', Icons.notes_outlined),
                        ),
                        SizedBox(height: Responsive.h(20)),
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.h(48),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              bloc.add(MarkIncentivePaid(
                                paymentReference: referenceController.text.trim(),
                                paymentDate: _formatDate(paymentDate),
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              ));
                              Navigator.pop(sheetContext);
                            },
                            child: Text(
                              'Confirm Payment',
                              style: AppTextStyles.bodyBold(color: Colors.white)
                                  .copyWith(fontSize: Responsive.sp(14)),
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
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(14)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<IncentiveDetailBloc, IncentiveDetailState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppSnackbar.success(state.successMessage!);
            context.read<IncentiveDetailBloc>().add(const ClearIncentiveDetailFeedback());
          } else if (state.errorMessage != null) {
            AppSnackbar.error(state.errorMessage!);
            context.read<IncentiveDetailBloc>().add(const ClearIncentiveDetailFeedback());
          }
        },
        builder: (context, state) {
          if (state.incentive == null) {
            if (state.status == IncentiveDetailStatus.error) {
              return _ErrorState(
                onRetry: () => context
                    .read<IncentiveDetailBloc>()
                    .add(LoadIncentiveDetail(context.read<IncentiveDetailBloc>().incentiveId)),
              );
            }
            // Covers both `initial` (first frame, before the async load
            // handler has run) and `loading`.
            return const Center(child: CircularProgressIndicator());
          }

          final incentive = state.incentive!;

          return SingleChildScrollView(
            child: Column(
              children: [
                _AmountHeader(incentive: incentive),
                Transform.translate(
                  offset: Offset(0, -Responsive.h(22)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                    child: Column(
                      children: [
                        _DetailCard(incentive: incentive),
                        if (incentive.notes.isNotEmpty) ...[
                          SizedBox(height: Responsive.h(14)),
                          _NotesBox(notes: incentive.notes),
                        ],
                        SizedBox(height: Responsive.h(20)),
                        if (incentive.status != 'paid')
                          SizedBox(
                            width: double.infinity,
                            height: Responsive.h(50),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                                  : Text(
                                'Mark as Paid',
                                style: AppTextStyles.bodyBold(color: Colors.white)
                                    .copyWith(fontSize: Responsive.sp(15)),
                              ),
                            ),
                          ),
                        SizedBox(height: Responsive.h(24)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AmountHeader extends StatelessWidget {
  const _AmountHeader({required this.incentive});

  final FieldStaffIncentiveModel incentive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(16),
        Responsive.h(8),
        Responsive.w(16),
        Responsive.h(50),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.w(28)),
          bottomRight: Radius.circular(Responsive.w(28)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Incentive Detail',
                    style: AppTextStyles.h6().copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            SizedBox(height: Responsive.h(12)),
            Text(
              '₹${incentive.incentiveAmountFormatted}',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.sp(32),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: Responsive.h(4)),
            Text(
              'Incentive for site visit',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: Responsive.sp(12.5)),
            ),
            SizedBox(height: Responsive.h(10)),
            _StatusPillLarge(status: incentive.status, label: incentive.statusLabel),
          ],
        ),
      ),
    );
  }
}

class _StatusPillLarge extends StatelessWidget {
  const _StatusPillLarge({required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(6)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'paid'
                ? Icons.check_circle_outline
                : status == 'approved'
                ? Icons.verified_outlined
                : Icons.hourglass_top_outlined,
            size: 15,
            color: Colors.white,
          ),
          SizedBox(width: Responsive.w(6)),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w600),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Field Staff', value: incentive.fieldStaffName),
          _DetailRow(label: 'Customer', value: incentive.siteVisit.customerName),
          _DetailRow(label: 'Site Address', value: incentive.siteVisit.siteAddress),
          _DetailRow(label: 'Visit Date', value: incentive.siteVisit.visitDate),
          _DetailRow(label: 'Linked Estimate', value: incentive.estimateNumber),
          _DetailRow(label: 'Created', value: incentive.createdAt, isLast: true),
          if (incentive.status == 'paid' && incentive.paidAt.isNotEmpty)
            _DetailRow(label: 'Paid On', value: incentive.paidAt, isLast: true),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.isLast = false});

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
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12.5)),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.black,
                fontSize: Responsive.sp(13),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0D999)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTES',
            style: TextStyle(
              color: const Color(0xFF9A7115),
              fontSize: Responsive.sp(11),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: Responsive.h(6)),
          Text(
            notes,
            style: TextStyle(color: const Color(0xFF6B5316), fontSize: Responsive.sp(12.5)),
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
            Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(12)),
            Text(
              'Could not load incentive',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
            SizedBox(height: Responsive.h(16)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}