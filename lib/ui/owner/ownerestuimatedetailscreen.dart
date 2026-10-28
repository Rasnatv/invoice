import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatedetailscreenwidget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';
import '../../core/validator/validationfile.dart';
import '../../models/owner_models/owner_estimateactionmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';
import 'owner_estimateupdation.dart';
import 'ownerdespatchsheet.dart';

// PDF generation + native share sheet (WhatsApp, Email, Drive, etc.)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Noto Sans -> has the ₹ glyph
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Excel export
import 'package:excel/excel.dart' as xls;

const Color _redColor = Color(0xFFDC2626);

class OwnerEstimateDetailsScreen extends StatelessWidget {
  const OwnerEstimateDetailsScreen({super.key, required this.estimateId});
  final String estimateId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerEstimateDetailBloc()
        ..add(OwnerEstimateDetailLoadRequested(estimateId)),
      child: OwnerEstimateDetailView(estimateId: estimateId),
    );
  }
}

Future<void> openUpdateScreen(BuildContext context, EstimateDetailModel detail) async {
  final bloc = context.read<OwnerEstimateDetailBloc>();
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: OwnerEstimateUpdateScreen(detail: detail),
      ),
    ),
  );
  // Reload after coming back so the page always shows the latest data.
  bloc.add(OwnerEstimateDetailLoadRequested(detail.id));
}

class OwnerEstimateDetailView extends StatefulWidget {
  const OwnerEstimateDetailView({super.key, required this.estimateId});
  final String estimateId;

  @override
  State<OwnerEstimateDetailView> createState() => OwnerEstimateDetailViewState();
}

class OwnerEstimateDetailViewState extends State<OwnerEstimateDetailView> {
  // spinner state while PDF / Excel is being built + handed to the share sheet.
  bool isGeneratingPdf = false;
  bool isGeneratingExcel = false;

  static const _appBarSpinner = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  bool checkIsOwner(EstimateDetailModel detail) {
    return detail.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
  }

  /// Manual refresh (pull-to-refresh + app bar button).
  /// Fires a reload and waits until the bloc finishes loading so the
  /// RefreshIndicator spinner stays visible for the right duration.
  Future<void> refresh(BuildContext context) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();
    bloc.add(OwnerEstimateDetailLoadRequested(widget.estimateId));

    await bloc.stream
        .firstWhere(
          (s) =>
      s.status != OwnerEstimateDetailStatus.loading &&
          s.status != OwnerEstimateDetailStatus.initial,
    )
        .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final number = NumberFormat.decimalPattern('en_IN');

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Drivers / Estimates) ----------
        appBar: AppBar(
          title: Text('Owner Estimate Details', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            Builder(builder: (context) {
              return IconButton(
                tooltip: 'Share as PDF',
                icon: isGeneratingPdf
                    ? _appBarSpinner
                    : const Icon(Icons.picture_as_pdf_rounded),
                onPressed: isGeneratingPdf
                    ? null
                    : () {
                  final detail = context.read<OwnerEstimateDetailBloc>().state.detail;
                  if (detail == null) {
                    AppSnackbar.error('Estimate data not loaded yet');
                    return;
                  }
                  generateAndSharePdf(detail, checkIsOwner(detail));
                },
              );
            }),
            // Share as Excel -> native share sheet -> WhatsApp/etc.
            Builder(builder: (context) {
              return IconButton(
                tooltip: 'Share as Excel',
                icon: isGeneratingExcel
                    ? _appBarSpinner
                    : const Icon(Icons.grid_on_rounded),
                onPressed: isGeneratingExcel
                    ? null
                    : () {
                  final detail = context.read<OwnerEstimateDetailBloc>().state.detail;
                  if (detail == null) {
                    AppSnackbar.error('Estimate data not loaded yet');
                    return;
                  }
                  generateAndShareExcel(detail, checkIsOwner(detail));
                },
              );
            }),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
            // Only react when the action status actually changes, so the
            // snackbar doesn't re-fire on every later emit.
            listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
            listener: (context, state) {
              if (state.actionStatus == OwnerEstimateActionStatus.success) {
                AppSnackbar.success(state.actionMessage ?? 'Done');
              } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
                AppSnackbar.error(state.actionMessage ?? 'Action failed');
              }
            },
            builder: (context, state) {
              // ---- loading ----
              // Only when there is nothing to show yet. During a refresh the
              // old data stays on screen.
              if ((state.status == OwnerEstimateDetailStatus.loading ||
                  state.status == OwnerEstimateDetailStatus.initial) &&
                  state.detail == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // ---- error ----
              if (state.status == OwnerEstimateDetailStatus.failure ||
                  state.detail == null) {
                return RefreshIndicator(
                  onRefresh: () => refresh(context),
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: _ErrorView(
                          message: state.errorMessage ?? 'Failed to load estimate.',
                          onRetry: () => context
                              .read<OwnerEstimateDetailBloc>()
                              .add(OwnerEstimateDetailLoadRequested(widget.estimateId)),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final detail = state.detail!;
              final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;
              final isOwner = checkIsOwner(detail);

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => refresh(context),
                      child: ListView(
                        // Needed so pull-to-refresh works even when content is short
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: listPadding,
                        children: [
                          EstimateHeader(detail: detail),
                          SizedBox(height: Responsive.h(14)),
                          if (detail.notes.isNotEmpty) ...[
                            DetailSection(
                              title: 'Notes',
                              icon: Icons.sticky_note_2_outlined,
                              rows: [
                                DetailRow('Notes', detail.notes,
                                    icon: Icons.sticky_note_2_outlined),
                              ],
                            ),
                            SizedBox(height: Responsive.h(14)),
                          ],
                          DetailSection(
                            title: 'Customer Details',
                            icon: Icons.groups_2_outlined,
                            rows: [
                              DetailRow('Name', detail.customerName,
                                  icon: Icons.groups_2_outlined),
                              DetailRow('Phone', detail.customerPhone,
                                  icon: Icons.phone_outlined),
                              DetailRow('Email', detail.customerEmail,
                                  icon: Icons.email_outlined),
                              DetailRow('Address', detail.customerAddress,
                                  icon: Icons.location_on_outlined),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),
                          DetailSection(
                            title: 'Contractor Details',
                            icon: Icons.person_outline,
                            rows: [
                              DetailRow('Name', detail.customer.name,
                                  icon: Icons.person_outline),
                              DetailRow('Phone', detail.customer.phone,
                                  icon: Icons.phone_outlined),
                              DetailRow('Email', detail.customer.email,
                                  icon: Icons.email_outlined),
                            ],
                          ),
                          if (detail.salesman.name.isNotEmpty) ...[
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Salesman',
                              icon: Icons.badge_outlined,
                              rows: [
                                DetailRow('Name', detail.salesman.name,
                                    icon: Icons.badge_outlined),
                              ],
                            ),
                          ],
                          if (detail.isApproved) ...[
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Approval',
                              icon: Icons.check_circle_outline,
                              rows: [
                                DetailRow(
                                  'Approved By',
                                  detail.approvedByDetails.name.isNotEmpty
                                      ? detail.approvedByDetails.name
                                      : detail.approvedBy,
                                  icon: Icons.check_circle_outline,
                                ),
                                if (detail.approvedAt.isNotEmpty)
                                  DetailRow('Approved At', detail.approvedAt,
                                      icon: Icons.event_outlined),
                                if (detail.approvalNotes.isNotEmpty)
                                  DetailRow('Notes', detail.approvalNotes,
                                      icon: Icons.info_outline),
                              ],
                            ),
                          ],
                          if (detail.quotation.exists) ...[
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Linked Quotation',
                              icon: Icons.description_outlined,
                              rows: [
                                DetailRow('Quotation No.', detail.quotation.quotationNumber,
                                    icon: Icons.description_outlined),
                                DetailRow('Status', detail.quotation.status,
                                    icon: Icons.flag_outlined),
                              ],
                            ),
                          ],
                          SizedBox(height: Responsive.h(18)),
                          EstimateItemsTable(
                              detail: detail, number: number, isOwner: isOwner),
                          SizedBox(height: Responsive.h(14)),
                          EstimateSummary(detail: detail, number: number),
                          if (detail.payments.isNotEmpty) ...[
                            SizedBox(height: Responsive.h(14)),
                            EstimatePayments(detail: detail),
                          ],
                        ],
                      ),
                    ),
                  ),
                  buildBottomBar(context, detail, isBusy),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Reject dialog
  // ---------------------------------------------------------------------

  /// Same field look as the Drivers sheet: hint only, filled, no border.
  InputDecoration _dialogFieldDecoration({String? hint, String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: AppTextStyles.body(color: AppColors.textHint),
      labelStyle: AppTextStyles.body(color: AppColors.textSecondary),
      errorStyle: AppTextStyles.caption(color: AppColors.error),
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
    );
  }

  Future<void> showRejectDialog(BuildContext context, EstimateDetailModel detail) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reject Estimate', style: AppTextStyles.bodyBold()),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            style: AppTextStyles.body(),
            decoration: _dialogFieldDecoration(
              hint: 'Why is this estimate being rejected?',
            ),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Reason is required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(reasonController.text.trim());
              }
            },
            child: Text('Reject', style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      bloc.add(OwnerEstimateRejectRequested(
        OwnerRejectEstimateRequest(id: detail.id, rejectionNotes: result),
      ));
    }
  }

  // ---------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------

  Widget buildBottomBar(BuildContext context, EstimateDetailModel detail, bool isBusy) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(20), Responsive.h(10), Responsive.w(20), Responsive.h(14)),
        child: buildActionBar(context, detail, isBusy),
      ),
    );
  }

  Widget buildActionBar(BuildContext context, EstimateDetailModel detail, bool isBusy) {
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final buttonHeight = Responsive.h(48);

    if (detail.isPendingApproval) {
      return Row(
        children: [
          RoundIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'Update',
            onPressed: () => openUpdateScreen(context, detail),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _redColor,
                  side: const BorderSide(color: _redColor),
                  shape: buttonShape,
                ),
                onPressed: isBusy ? null : () => showRejectDialog(context, detail),
                child: Text('Reject', style: AppTextStyles.bodyBold(color: _redColor)),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: buttonShape,
                ),
                onPressed: isBusy ? null : () => showApproveDialog(context, detail),
                child: Text(
                  isBusy ? 'Please wait...' : 'Approve',
                  style: AppTextStyles.bodyBold(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (detail.status.toLowerCase() == 'rejected') {
      return Container(
        width: double.infinity,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _redColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _redColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_rounded, size: 18, color: _redColor),
            SizedBox(width: Responsive.w(6)),
            Text('Rejected', style: AppTextStyles.bodyBold(color: _redColor)),
          ],
        ),
      );
    }

    // APPROVED, not despatched yet: only the despatch button shows here.
    if (detail.status.toLowerCase() == 'approved') {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: buttonShape,
          ),
          onPressed: () => openDespatchSheet(context, detail),
          child: Text('Send to Despatch',
              style: AppTextStyles.bodyBold(color: Colors.white)),
        ),
      );
    }

    // DESPATCHED / DELIVERED (or any other status): read-only status pill.
    return Container(
      width: double.infinity,
      height: buttonHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon(detail.status), size: 18, color: AppColors.success),
          SizedBox(width: Responsive.w(6)),
          Text(statusLabel(detail.status),
              style: AppTextStyles.bodyBold(color: AppColors.success)),
        ],
      ),
    );
  }

  Future<void> openDespatchSheet(BuildContext context, EstimateDetailModel detail) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(estimateId: detail.id),
      ),
    );

    if (created == true) {
      bloc.add(OwnerEstimateDetailLoadRequested(detail.id));
    }
  }

  // ---------------------------------------------------------------------
  // Approve dialog
  // ---------------------------------------------------------------------
  //
  // Future<void> showApproveDialog(BuildContext context, EstimateDetailModel detail) async {
  //   final bloc = context.read<OwnerEstimateDetailBloc>();
  //   final formKey = GlobalKey<FormState>();
  //
  //   // One set of styles for the whole dialog.
  //   final headingStyle = AppTextStyles.bodyBold(); // titles, headings
  //   final inputStyle = AppTextStyles.body(); // typed text, dropdown items
  //   final labelStyle = AppTextStyles.body(color: AppColors.textSecondary); // labels, hints
  //   final errorStyle = AppTextStyles.caption(color: AppColors.error); // validation messages
  //
  //   final handlingCtrl = TextEditingController(
  //       text: detail.handlingCharge > 0 ? detail.handlingCharge.toStringAsFixed(0) : '');
  //   final notesCtrl = TextEditingController();
  //   String discountType = 'none'; // none | percentage | fixed
  //   final discountValueCtrl = TextEditingController();
  //   final discountNotesCtrl = TextEditingController();
  //   final paymentAmountCtrl = TextEditingController();
  //   String paymentMethod = 'cash'; // cash | online | cheque | bank_transfer
  //   final paymentRefCtrl = TextEditingController();
  //   DateTime? paymentDate;
  //   final paymentNotesCtrl = TextEditingController();
  //
  //   // Pure frontend calculation, no API call. Re-run on every keystroke via
  //   // setLocal. subtotal + handling - discount = payable; payable - received = balance.
  //   ({double handling, double discount, double payable, double received, double balance})
  //   calcPreview() {
  //     final handling = double.tryParse(handlingCtrl.text.trim()) ?? detail.handlingCharge;
  //     final discountValue = double.tryParse(discountValueCtrl.text.trim()) ?? 0;
  //     final beforeDiscount = detail.subtotal + handling;
  //
  //     double discount = 0;
  //     if (discountType == 'percentage') {
  //       discount = beforeDiscount * (discountValue / 100);
  //     } else if (discountType == 'fixed') {
  //       discount = discountValue;
  //     }
  //     if (discount > beforeDiscount) discount = beforeDiscount;
  //
  //     final payable = beforeDiscount - discount;
  //     final received = double.tryParse(paymentAmountCtrl.text.trim()) ?? 0;
  //     final balance = (payable - received).clamp(0, double.infinity).toDouble();
  //
  //     return (
  //     handling: handling,
  //     discount: discount,
  //     payable: payable,
  //     received: received,
  //     balance: balance,
  //     );
  //   }
  //
  //   Widget previewRow(String label, String value, {bool bold = false, Color? color}) {
  //     final valueStyle = bold
  //         ? AppTextStyles.bodyBold(color: color ?? AppColors.textPrimary)
  //         : AppTextStyles.body(color: color ?? AppColors.textPrimary);
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 2),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Text(label,
  //               style: bold
  //                   ? AppTextStyles.bodyBold()
  //                   : AppTextStyles.body(color: AppColors.textSecondary)),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Align(
  //               alignment: Alignment.centerRight,
  //               child: FittedBox(
  //                 fit: BoxFit.scaleDown,
  //                 alignment: Alignment.centerRight,
  //                 child: Text(value, maxLines: 1, softWrap: false, style: valueStyle),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   await showDialog<void>(
  //     context: context,
  //     builder: (dialogContext) {
  //       return StatefulBuilder(
  //         builder: (dialogContext, setLocal) {
  //           final preview = calcPreview();
  //
  //           return Theme(
  //             data: Theme.of(dialogContext).copyWith(
  //               inputDecorationTheme: InputDecorationTheme(
  //                 labelStyle: labelStyle,
  //                 floatingLabelStyle: labelStyle,
  //                 hintStyle: labelStyle,
  //                 prefixStyle: inputStyle,
  //                 suffixStyle: inputStyle,
  //                 errorStyle: errorStyle,
  //                 filled: true,
  //                 fillColor: AppColors.background,
  //                 contentPadding: EdgeInsets.symmetric(
  //                   horizontal: Responsive.w(14),
  //                   vertical: Responsive.h(14),
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(14),
  //                   borderSide: BorderSide.none,
  //                 ),
  //               ),
  //               textTheme: Theme.of(dialogContext).textTheme.copyWith(
  //                 titleMedium: inputStyle, // typed text + dropdown value
  //                 bodyLarge: inputStyle,
  //               ),
  //             ),
  //             child: AlertDialog(
  //               backgroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //               title: Text('Approve Estimate', style: headingStyle),
  //               content: SizedBox(
  //                 width: double.maxFinite,
  //                 child: SingleChildScrollView(
  //                   child: Form(
  //                     key: formKey,
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         TextFormField(
  //                           controller: handlingCtrl,
  //                           style: inputStyle,
  //                           keyboardType:
  //                           const TextInputType.numberWithOptions(decimal: true),
  //                           inputFormatters: [
  //                             FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  //                           ],
  //                           decoration: const InputDecoration(
  //                             labelText: 'Handling Charge (optional)',
  //                             prefixText: '₹ ',
  //                           ),
  //                           onChanged: (_) => setLocal(() {}),
  //                         ),
  //                         const SizedBox(height: 16),
  //                         Text('Discount', style: headingStyle),
  //                         const SizedBox(height: 6),
  //                         DropdownButtonFormField<String>(
  //                           value: discountType,
  //                           style: inputStyle,
  //                           items: [
  //                             DropdownMenuItem(
  //                                 value: 'none',
  //                                 child: Text('No discount', style: inputStyle)),
  //                             DropdownMenuItem(
  //                                 value: 'percentage',
  //                                 child: Text('Percentage', style: inputStyle)),
  //                             DropdownMenuItem(
  //                                 value: 'fixed',
  //                                 child: Text('Fixed', style: inputStyle)),
  //                           ],
  //                           onChanged: (v) => setLocal(() => discountType = v ?? 'none'),
  //                         ),
  //                         if (discountType != 'none') ...[
  //                           const SizedBox(height: 12),
  //                           TextFormField(
  //                             controller: discountValueCtrl,
  //                             style: inputStyle,
  //                             keyboardType:
  //                             const TextInputType.numberWithOptions(decimal: true),
  //                             inputFormatters: [
  //                               FilteringTextInputFormatter.allow(
  //                                   RegExp(r'^\d*\.?\d{0,2}')),
  //                             ],
  //                             decoration: InputDecoration(
  //                               labelText: discountType == 'percentage'
  //                                   ? 'Discount %'
  //                                   : 'Discount Amount',
  //                               prefixText: discountType == 'fixed' ? '₹ ' : null,
  //                               suffixText: discountType == 'percentage' ? '%' : null,
  //                             ),
  //                             onChanged: (_) => setLocal(() {}),
  //                             validator: (v) {
  //                               if (discountType == 'none') return null;
  //                               if (v == null || v.trim().isEmpty) return 'Required';
  //                               final parsed = double.tryParse(v.trim());
  //                               if (parsed == null || parsed < 0) {
  //                                 return 'Enter a valid value';
  //                               }
  //                               if (discountType == 'percentage' && parsed > 99) {
  //                                 return 'Cannot exceed 99%';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           const SizedBox(height: 12),
  //                         ],
  //
  //                         // ---- PAYABLE AMOUNT: shown right before Amount Received ----
  //                         const SizedBox(height: 16),
  //                         Container(
  //                           width: double.infinity,
  //                           padding: const EdgeInsets.all(12),
  //                           decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.circular(14),
  //                             border: Border.all(color: AppColors.border),
  //                           ),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               previewRow('Subtotal', currencyFmt.f(detail.subtotal)),
  //                               previewRow('Handling Charge',
  //                                   '+ ${currencyFmt.f(preview.handling)}'),
  //                               if (discountType != 'none')
  //                                 previewRow(
  //                                   discountType == 'percentage'
  //                                       ? 'Discount (${discountValueCtrl.text.trim().isEmpty ? '0' : discountValueCtrl.text.trim()}%)'
  //                                       : 'Discount',
  //                                   '- ${currencyFmt.f(preview.discount)}',
  //                                   color: _redColor,
  //                                 ),
  //                               const Divider(height: 14, color: AppColors.border),
  //                               previewRow(
  //                                 'Payable Amount',
  //                                 currencyFmt.f(preview.payable),
  //                                 bold: true,
  //                                 color: AppColors.primary,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //
  //                         const SizedBox(height: 16),
  //                         Text('Initial Payment (optional)', style: headingStyle),
  //                         const SizedBox(height: 6),
  //                         TextFormField(
  //                           controller: paymentAmountCtrl,
  //                           style: inputStyle,
  //                           keyboardType:
  //                           const TextInputType.numberWithOptions(decimal: true),
  //                           inputFormatters: [
  //                             FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  //                           ],
  //                           decoration: const InputDecoration(
  //                             labelText: 'Amount Received',
  //                             prefixText: '₹ ',
  //                           ),
  //                           onChanged: (_) => setLocal(() {}),
  //                           validator: (v) {
  //                             if (v == null || v.trim().isEmpty) return null; // optional
  //                             final parsed = double.tryParse(v.trim());
  //                             if (parsed == null || parsed <= 0) {
  //                               return 'Enter a valid amount';
  //                             }
  //                             final payable = calcPreview().payable;
  //                             if (parsed > payable + 0.009) {
  //                               return 'Cannot exceed payable amount (${currencyFmt.f(payable)})';
  //                             }
  //                             return null;
  //                           },
  //                         ),
  //                         const SizedBox(height: 8),
  //                         // Live balance after the amount received.
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(horizontal: 2),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Text('Balance Due', style: AppTextStyles.bodyBold()),
  //                               Text(
  //                                 currencyFmt.f(preview.balance),
  //                                 style: AppTextStyles.bodyBold(
  //                                   color: preview.balance > 0
  //                                       ? _redColor
  //                                       : AppColors.success,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         DropdownButtonFormField<String>(
  //                           value: paymentMethod,
  //                           style: inputStyle,
  //                           decoration: const InputDecoration(labelText: 'Payment Method'),
  //                           items: [
  //                             DropdownMenuItem(
  //                                 value: 'cash', child: Text('Cash', style: inputStyle)),
  //                             DropdownMenuItem(
  //                                 value: 'online',
  //                                 child: Text('Online', style: inputStyle)),
  //                             DropdownMenuItem(
  //                                 value: 'cheque',
  //                                 child: Text('Cheque', style: inputStyle)),
  //                             DropdownMenuItem(
  //                                 value: 'bank_transfer',
  //                                 child: Text('Bank Transfer', style: inputStyle)),
  //                           ],
  //                           onChanged: (v) => setLocal(() => paymentMethod = v ?? 'cash'),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         TextFormField(
  //                           controller: paymentRefCtrl,
  //                           style: inputStyle,
  //                           decoration: const InputDecoration(
  //                             labelText: 'Payment Reference (optional)',
  //                           ),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         InkWell(
  //                           borderRadius: BorderRadius.circular(14),
  //                           onTap: () async {
  //                             final picked = await showDatePicker(
  //                               context: dialogContext,
  //                               initialDate: DateTime.now(),
  //                               firstDate: DateTime(2020),
  //                               lastDate: DateTime(2100),
  //                             );
  //                             if (picked != null) setLocal(() => paymentDate = picked);
  //                           },
  //                           child: InputDecorator(
  //                             decoration: const InputDecoration(
  //                               labelText: 'Payment Date (optional)',
  //                             ),
  //                             child: Text(
  //                               paymentDate == null
  //                                   ? 'Select date'
  //                                   : DateFormat('yyyy-MM-dd').format(paymentDate!),
  //                               style: inputStyle,
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         TextFormField(
  //                           controller: paymentNotesCtrl,
  //                           style: inputStyle,
  //                           decoration: const InputDecoration(
  //                             labelText: 'Payment Notes (optional)',
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(dialogContext).pop(),
  //                   child: Text('Cancel',
  //                       style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
  //                 ),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.primary,
  //                     elevation: 0,
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(14)),
  //                   ),
  //                   onPressed: () {
  //                     if (!formKey.currentState!.validate()) return;
  //
  //                     final request = OwnerApproveEstimateRequest(
  //                       estimateId: detail.id,
  //                       handlingCharge: handlingCtrl.text.trim().isEmpty
  //                           ? null
  //                           : double.tryParse(handlingCtrl.text.trim()),
  //                       approvalNotes: notesCtrl.text.trim().isEmpty
  //                           ? null
  //                           : notesCtrl.text.trim(),
  //                       discountType: discountType == 'none' ? null : discountType,
  //                       discountValue: discountType == 'none'
  //                           ? null
  //                           : double.tryParse(discountValueCtrl.text.trim()),
  //                       discountNotes: discountType == 'none' ||
  //                           discountNotesCtrl.text.trim().isEmpty
  //                           ? null
  //                           : discountNotesCtrl.text.trim(),
  //                       paymentAmount: paymentAmountCtrl.text.trim().isEmpty
  //                           ? null
  //                           : double.tryParse(paymentAmountCtrl.text.trim()),
  //                       paymentMethod: paymentAmountCtrl.text.trim().isEmpty
  //                           ? null
  //                           : paymentMethod,
  //                       paymentReference: paymentRefCtrl.text.trim().isEmpty
  //                           ? null
  //                           : paymentRefCtrl.text.trim(),
  //                       paymentDate: paymentDate == null
  //                           ? null
  //                           : DateFormat('yyyy-MM-dd').format(paymentDate!),
  //                       paymentNotes: paymentNotesCtrl.text.trim().isEmpty
  //                           ? null
  //                           : paymentNotesCtrl.text.trim(),
  //                     );
  //
  //                     Navigator.of(dialogContext).pop();
  //                     bloc.add(OwnerEstimateApproveRequested(request));
  //                   },
  //                   child: Text('Approve',
  //                       style: AppTextStyles.bodyBold(color: Colors.white)),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  // =====================================================================
// 1) ADD THIS IMPORT at the top of the estimate detail screen file
// =====================================================================
// import '../../core/validator/validationfile.dart';

// =====================================================================
// 2) REPLACE the whole existing `showApproveDialog` method inside
//    OwnerEstimateDetailViewState with this one.
// =====================================================================

  Future<void> showApproveDialog(BuildContext context, EstimateDetailModel detail) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();
    final formKey = GlobalKey<FormState>();

    // One set of styles for the whole dialog.
    final headingStyle = AppTextStyles.bodyBold(); // titles, headings
    final inputStyle = AppTextStyles.body(); // typed text, dropdown items
    final labelStyle = AppTextStyles.body(color: AppColors.textSecondary); // labels, hints
    final errorStyle = AppTextStyles.caption(color: AppColors.error); // validation messages

    final handlingCtrl = TextEditingController(
        text: detail.handlingCharge > 0 ? detail.handlingCharge.toStringAsFixed(0) : '');
    final notesCtrl = TextEditingController();
    String discountType = 'none'; // none | percentage | fixed
    final discountValueCtrl = TextEditingController();
    final discountNotesCtrl = TextEditingController();
    final paymentAmountCtrl = TextEditingController();
    String paymentMethod = 'cash'; // cash | online | cheque | bank_transfer
    final paymentRefCtrl = TextEditingController();
    DateTime? paymentDate;
    final paymentNotesCtrl = TextEditingController();

    // Pure frontend calculation, no API call. Re-run on every keystroke via
    // setLocal. subtotal + handling - discount = payable; payable - received = balance.
    ({double handling, double discount, double payable, double received, double balance})
    calcPreview() {
      final handling = double.tryParse(handlingCtrl.text.trim()) ?? detail.handlingCharge;
      final discountValue = double.tryParse(discountValueCtrl.text.trim()) ?? 0;
      final beforeDiscount = detail.subtotal + handling;

      double discount = 0;
      if (discountType == 'percentage') {
        discount = beforeDiscount * (discountValue / 100);
      } else if (discountType == 'fixed') {
        discount = discountValue;
      }
      if (discount > beforeDiscount) discount = beforeDiscount;

      final payable = beforeDiscount - discount;
      final received = double.tryParse(paymentAmountCtrl.text.trim()) ?? 0;
      final balance = (payable - received).clamp(0, double.infinity).toDouble();

      return (
      handling: handling,
      discount: discount,
      payable: payable,
      received: received,
      balance: balance,
      );
    }

    Widget previewRow(String label, String value, {bool bold = false, Color? color}) {
      final valueStyle = bold
          ? AppTextStyles.bodyBold(color: color ?? AppColors.textPrimary)
          : AppTextStyles.body(color: color ?? AppColors.textPrimary);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label,
                style: bold
                    ? AppTextStyles.bodyBold()
                    : AppTextStyles.body(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(value, maxLines: 1, softWrap: false, style: valueStyle),
                ),
              ),
            ),
          ],
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            final preview = calcPreview();

            return Theme(
              data: Theme.of(dialogContext).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: labelStyle,
                  floatingLabelStyle: labelStyle,
                  hintStyle: labelStyle,
                  prefixStyle: inputStyle,
                  suffixStyle: inputStyle,
                  errorStyle: errorStyle,
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
                textTheme: Theme.of(dialogContext).textTheme.copyWith(
                  titleMedium: inputStyle, // typed text + dropdown value
                  bodyLarge: inputStyle,
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Approve Estimate', style: headingStyle),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- Handling Charge ----------
                          TextFormField(
                            controller: handlingCtrl,
                            style: inputStyle,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: DValidator.priceNumber, // 8 digits + 2 decimals
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Handling Charge (optional)',
                              prefixText: '₹ ',
                            ),
                            onChanged: (_) => setLocal(() {}),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null; // optional
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed < 0) {
                                return 'Enter a valid amount';
                              }
                              if (parsed > DValidator.maxPrice) {
                                return 'Amount can have at most ${DValidator.maxPriceDigits} digits';
                              }
                              return null;
                            },
                          ),

                          // ---------- Discount ----------
                          const SizedBox(height: 16),
                          Text('Discount', style: headingStyle),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: discountType,
                            style: inputStyle,
                            items: [
                              DropdownMenuItem(
                                  value: 'none',
                                  child: Text('No discount', style: inputStyle)),
                              DropdownMenuItem(
                                  value: 'percentage',
                                  child: Text('Percentage', style: inputStyle)),
                              DropdownMenuItem(
                                  value: 'fixed',
                                  child: Text('Fixed', style: inputStyle)),
                            ],
                            // Clear the value when the type changes so "50%" doesn't
                            // silently become a fixed ₹50 discount.
                            onChanged: (v) => setLocal(() {
                              discountType = v ?? 'none';
                              discountValueCtrl.clear();
                            }),
                          ),
                          if (discountType != 'none') ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: discountValueCtrl,
                              style: inputStyle,
                              keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: DValidator.decimalWithLimit(
                                maxIntDigits: discountType == 'percentage'
                                    ? 3
                                    : DValidator.maxPriceDigits,
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: discountType == 'percentage'
                                    ? 'Discount %'
                                    : 'Discount Amount',
                                prefixText: discountType == 'fixed' ? '₹ ' : null,
                                suffixText: discountType == 'percentage' ? '%' : null,
                              ),
                              onChanged: (_) => setLocal(() {}),
                              validator: (v) {
                                if (discountType == 'none') return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter a value or choose "No discount"';
                                }
                                final parsed = double.tryParse(v.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'Enter a valid value';
                                }
                                if (discountType == 'percentage') {
                                  if (parsed > 99) return 'Cannot exceed 99%';
                                } else {
                                  if (parsed > DValidator.maxPrice) {
                                    return 'Amount can have at most ${DValidator.maxPriceDigits} digits';
                                  }
                                  // Fixed discount can't be more than subtotal + handling
                                  final beforeDiscount =
                                      detail.subtotal + calcPreview().handling;
                                  if ((parsed * 100).round() >
                                      (beforeDiscount * 100).round()) {
                                    return 'Cannot exceed ${currencyFmt.f(beforeDiscount)}';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ---- PAYABLE AMOUNT: shown right before Amount Received ----
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                previewRow('Subtotal', currencyFmt.f(detail.subtotal)),
                                previewRow('Handling Charge',
                                    '+ ${currencyFmt.f(preview.handling)}'),
                                if (discountType != 'none')
                                  previewRow(
                                    discountType == 'percentage'
                                        ? 'Discount (${discountValueCtrl.text.trim().isEmpty ? '0' : discountValueCtrl.text.trim()}%)'
                                        : 'Discount',
                                    '- ${currencyFmt.f(preview.discount)}',
                                    color: _redColor,
                                  ),
                                const Divider(height: 14, color: AppColors.border),
                                previewRow(
                                  'Payable Amount',
                                  currencyFmt.f(preview.payable),
                                  bold: true,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),

                          // ---------- Initial Payment ----------
                          const SizedBox(height: 16),
                          Text('Initial Payment (optional)', style: headingStyle),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: paymentAmountCtrl,
                            style: inputStyle,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: DValidator.paymentAmount, // 15 digits + 2 decimals
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Amount Received',
                              prefixText: '₹ ',
                              errorMaxLines: 3,
                            ),
                            onChanged: (_) => setLocal(() {}),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null; // optional
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              if (parsed.truncate().toString().length >
                                  DValidator.maxPaymentDigits) {
                                return 'Amount can have at most ${DValidator.maxPaymentDigits} digits';
                              }
                              final payable = calcPreview().payable;
                              // Compare in paise to avoid floating-point issues
                              if ((parsed * 100).round() > (payable * 100).round()) {
                                return 'Cannot exceed payable amount (${currencyFmt.f(payable)})';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          // Live balance after the amount received.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Balance Due', style: AppTextStyles.bodyBold()),
                                Text(
                                  currencyFmt.f(preview.balance),
                                  style: AppTextStyles.bodyBold(
                                    color: preview.balance > 0
                                        ? _redColor
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: paymentMethod,
                            style: inputStyle,
                            decoration: const InputDecoration(labelText: 'Payment Method'),
                            items: [
                              DropdownMenuItem(
                                  value: 'cash', child: Text('Cash', style: inputStyle)),
                              DropdownMenuItem(
                                  value: 'online',
                                  child: Text('Online', style: inputStyle)),
                              DropdownMenuItem(
                                  value: 'cheque',
                                  child: Text('Cheque', style: inputStyle)),
                              DropdownMenuItem(
                                  value: 'bank_transfer',
                                  child: Text('Bank Transfer', style: inputStyle)),
                            ],
                            onChanged: (v) => setLocal(() => paymentMethod = v ?? 'cash'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: paymentRefCtrl,
                            style: inputStyle,
                            decoration: const InputDecoration(
                              labelText: 'Payment Reference (optional)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setLocal(() => paymentDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Payment Date (optional)',
                              ),
                              child: Text(
                                paymentDate == null
                                    ? 'Select date'
                                    : DateFormat('yyyy-MM-dd').format(paymentDate!),
                                style: inputStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: paymentNotesCtrl,
                            style: inputStyle,
                            decoration: const InputDecoration(
                              labelText: 'Payment Notes (optional)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('Cancel',
                        style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final request = OwnerApproveEstimateRequest(
                        estimateId: detail.id,
                        handlingCharge: handlingCtrl.text.trim().isEmpty
                            ? null
                            : double.tryParse(handlingCtrl.text.trim()),
                        approvalNotes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                        discountType: discountType == 'none' ? null : discountType,
                        discountValue: discountType == 'none'
                            ? null
                            : double.tryParse(discountValueCtrl.text.trim()),
                        discountNotes: discountType == 'none' ||
                            discountNotesCtrl.text.trim().isEmpty
                            ? null
                            : discountNotesCtrl.text.trim(),
                        paymentAmount: paymentAmountCtrl.text.trim().isEmpty
                            ? null
                            : double.tryParse(paymentAmountCtrl.text.trim()),
                        paymentMethod: paymentAmountCtrl.text.trim().isEmpty
                            ? null
                            : paymentMethod,
                        paymentReference: paymentRefCtrl.text.trim().isEmpty
                            ? null
                            : paymentRefCtrl.text.trim(),
                        paymentDate: paymentDate == null
                            ? null
                            : DateFormat('yyyy-MM-dd').format(paymentDate!),
                        paymentNotes: paymentNotesCtrl.text.trim().isEmpty
                            ? null
                            : paymentNotesCtrl.text.trim(),
                      );

                      Navigator.of(dialogContext).pop();
                      bloc.add(OwnerEstimateApproveRequested(request));
                    },
                    child: Text('Approve',
                        style: AppTextStyles.bodyBold(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // PDF export + share
  // ---------------------------------------------------------------------

  Future<void> generateAndSharePdf(EstimateDetailModel d, bool isOwner) async {
    setState(() => isGeneratingPdf = true);
    try {
      final baseFont = await PdfGoogleFonts.notoSansRegular();
      final boldFont = await PdfGoogleFonts.notoSansBold();

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Estimate Details',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColors.grey400),
            ],
          ),
          build: (context) => [
            pdfInfoSection(d),
            pw.SizedBox(height: 18),
            pw.Text('Items',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            // pdfItemsTable(d, isOwner),
            pdfItemsTable(d, true), //
            pw.SizedBox(height: 14),
            pdfSummarySection(d),
            if (d.payments.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text('Payments',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pdfPaymentsTable(d),
            ],
          ],
        ),
      );

      final bytes = await pdf.save();

      final safeRef = d.estimateNumber.isNotEmpty
          ? d.estimateNumber.replaceAll(RegExp(r'[^\w\-]'), '_')
          : d.id;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Estimate_$safeRef.pdf');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Estimate - ${d.estimateNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate PDF: $e');
    } finally {
      if (mounted) setState(() => isGeneratingPdf = false);
    }
  }

  // ---------------------------------------------------------------------
  // Excel export + share
  // ---------------------------------------------------------------------

  Future<void> generateAndShareExcel(EstimateDetailModel d, bool isOwner) async {
    setState(() => isGeneratingExcel = true);
    try {
      final excelFile = xls.Excel.createExcel();
      const sheetName = 'Estimate';
      final sheet = excelFile[sheetName];
      excelFile.setDefaultSheet(sheetName);

      void addRow(List<dynamic> values) {
        sheet.appendRow(values.map((v) => xls.TextCellValue(v.toString())).toList());
      }

      // Same "only if at least one item has it" rule as the on-screen
      // table and the PDF export, so all three stay in sync.
      final hasBoxQty = d.items.any((i) => i.boxQuantity > 0);
      final hasPieceQty = d.items.any((i) => i.pieceQuantity > 0);

      addRow(['Estimate Details']);
      addRow([]);
      addRow(['Reference No.', d.estimateNumber]);
      addRow(['Date', d.dateRaw]);
      addRow(['Status', statusLabel(d.status)]);
      addRow(['Customer Name', d.customerName]);
      addRow(['Customer Phone', d.customerPhone]);
      addRow(['Customer Email', d.customerEmail]);
      addRow(['Customer Address', d.customerAddress]);
      addRow(['Contractor Name', d.customer.name]);
      addRow(['Contractor Phone', d.customer.phone]);
      if (d.salesman.name.isNotEmpty) addRow(['Salesman', d.salesman.name]);
      if (d.notes.isNotEmpty) addRow(['Notes', d.notes]);
      addRow([]);

      final headers = [
        '#',
        'Item',
        'Company',
        'Size',
        'Unit',
        'Qty',
        if (hasBoxQty) 'Box Qty',
        if (hasPieceQty) 'Piece Qty',
        'MRP',
        'Rate',
        'Amount',
        if (!isOwner) 'Incentive',
      ];
      addRow(headers);
      for (var i = 0; i < d.items.length; i++) {
        final item = d.items[i];
        addRow([
          i + 1,
          item.productName,
          item.companyName.isEmpty ? '-' : item.companyName,
          item.productSize.isEmpty ? '-' : item.productSize,
          item.unitName.isEmpty ? '-' : item.unitName,
          item.quantity.toStringAsFixed(0),
          if (hasBoxQty) (item.boxQuantity > 0 ? item.boxQuantity.toStringAsFixed(0) : '-'),
          if (hasPieceQty)
            (item.pieceQuantity > 0 ? item.pieceQuantity.toStringAsFixed(0) : '-'),
          item.mrp > 0 ? item.mrp.toStringAsFixed(0) : '-',
          item.rate.toStringAsFixed(0),
          currencyFmt.f(item.amount),
          if (!isOwner) (item.isIncentiveEligible ? currencyFmt.f(item.incentiveAmount) : '-'),
        ]);
      }
      addRow([]);

      // Same order as the on-screen summary card.
      addRow(['Subtotal', currencyFmt.f(d.subtotal)]);
      addRow(['Handling Charge', currencyFmt.f(d.handlingCharge)]);
      if (d.hasDiscount) {
        addRow(['Amount Before Discount', currencyFmt.f(d.grandTotal)]);
        addRow([
          'Discount (${d.discountTypeLabel.isEmpty ? d.discountType : d.discountTypeLabel})',
          '- ${currencyFmt.f(d.discountAmount)}'
        ]);
        addRow(['Grand Total', currencyFmt.f(d.amountAfterDiscount)]);
      } else {
        addRow(['Grand Total', currencyFmt.f(d.grandTotal)]);
      }
      addRow(['Total Paid', currencyFmt.f(d.totalPaid)]);
      addRow(['Balance Amount', currencyFmt.f(d.balanceAmount)]);

      if (d.payments.isNotEmpty) {
        addRow([]);
        addRow(['Payments']);
        addRow(['Method', 'Amount', 'Date']);
        for (final p in d.payments) {
          addRow([
            paymentMethodText(p),
            currencyFmt.f(p.amount),
            paymentDateText(p).isEmpty ? '-' : paymentDateText(p),
          ]);
        }
      }

      final bytes = excelFile.save();
      if (bytes == null) throw Exception('Could not generate Excel file');

      final safeRef = d.estimateNumber.isNotEmpty
          ? d.estimateNumber.replaceAll(RegExp(r'[^\w\-]'), '_')
          : d.id;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Estimate_$safeRef.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        text: 'Estimate - ${d.estimateNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate Excel file: $e');
    } finally {
      if (mounted) setState(() => isGeneratingExcel = false);
    }
  }
}

// =====================================================================
// ERROR VIEW (private to this file)
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