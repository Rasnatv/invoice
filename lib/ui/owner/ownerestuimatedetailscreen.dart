
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/primary_button.dart';
import 'ownerdespatchsheet.dart';



enum _DummyBillType { quotation, invoice }

extension on _DummyBillType {
  String get label => this == _DummyBillType.quotation ? 'Quotation' : 'Invoice';
}

enum _DummyStatus { pending, approved, rejected }

extension on _DummyStatus {
  String get label {
    switch (this) {
      case _DummyStatus.pending:
        return 'Pending';
      case _DummyStatus.approved:
        return 'Approved';
      case _DummyStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case _DummyStatus.pending:
        return Colors.orange;
      case _DummyStatus.approved:
        return Colors.green;
      case _DummyStatus.rejected:
        return Colors.red;
    }
  }
}

class _DummyItem {
  final String name;
  final String company;
  final String size;
  final double quantity;
  final String unit;
  final double mrp;
  final double rate;

  const _DummyItem({
    required this.name,
    required this.company,
    required this.size,
    required this.quantity,
    required this.unit,
    required this.mrp,
    required this.rate,
  });

  double get amount => quantity * rate;
}

class _DummyEstimate {
  final String id;
  // Party Name / Address / Phone — the top "Party Name" block on the
  // sheet, separate from the Contractor block further down.
  final String partyName;
  final String partyAddress;
  final String partyPhone;
  final String contractorName;
  final String siteAddress;
  final String phone;
  final String salesmanName;
  final DateTime date;
  final _DummyBillType billType;
  final _DummyStatus status;
  // Handling charge — entered by the salesman while creating the
  // estimate. It's optional: not every estimate has one, so this is
  // nullable rather than defaulting to 0. When null, the UI shows "-"
  // instead of a fabricated amount.
  final double? handlingCharge;
  // Total square footage — shown as "Total Sqrft" on the sheet.
  final double totalSqrft;
  final List<_DummyItem> items;

  // TRUE  -> a salesman submitted this estimate (incentive block shown).
  // FALSE -> the owner created this estimate directly (no incentive shown).
  final bool createdBySalesman;

  const _DummyEstimate({
    required this.id,
    required this.partyName,
    required this.partyAddress,
    required this.partyPhone,
    required this.contractorName,
    required this.siteAddress,
    required this.phone,
    required this.salesmanName,
    required this.date,
    required this.billType,
    required this.status,
    this.handlingCharge,
    required this.totalSqrft,
    required this.items,
    this.createdBySalesman = true,
  });

  double get mrpTotal => items.fold(0.0, (s, i) => s + i.mrp * i.quantity);
  double get itemsTotal => items.fold(0.0, (s, i) => s + i.amount);
  double get totalAmount => itemsTotal + (handlingCharge ?? 0);

  static _DummyEstimate sample() {
    return _DummyEstimate(
      id: 'EST-1042',
      partyName: 'Ramesh Constructions',
      partyAddress: 'No. 24, Palace Road, Kanhangad',
      partyPhone: '+91 90000 12345',
      contractorName: 'Ramesh Constructions',
      siteAddress: 'No. 24, Palace Road, Kanhangad',
      phone: '+91 98765 43210',
      salesmanName: 'Anoop Menon',
      date: DateTime.now(),
      billType: _DummyBillType.quotation,
      status: _DummyStatus.pending,
      // Set this to null to preview the "salesman didn't add a handling
      // charge" empty state — the summary card will show "-" instead.
      handlingCharge: 250,
      totalSqrft: 1000,
      createdBySalesman: true, // set false to preview the "owner created, no incentive" case
      items: const [
        _DummyItem(
          name: 'PVC Pipe',
          company: 'Supreme',
          size: '1 inch',
          quantity: 40,
          unit: 'Nos',
          mrp: 120,
          rate: 105,
        ),
        _DummyItem(
          name: 'Cement Bag',
          company: 'UltraTech',
          size: '50kg',
          quantity: 20,
          unit: 'Bag',
          mrp: 420,
          rate: 390,
        ),
        _DummyItem(
          name: 'Copper Wire',
          company: 'Havells',
          size: '2.5 sqmm',
          quantity: 8,
          unit: 'Coil',
          mrp: 2100,
          rate: 1950,
        ),
      ],
    );
  }
}

// Same placeholder incentive % pattern used elsewhere in the app — replace
// once admin-config exposes a real per-product incentive %.
const double _dummyIncentivePercent = 5.0;

double _incentiveAmountFor(_DummyItem item) => item.amount * _dummyIncentivePercent / 100;

// Dummy list of salesmen the owner can choose from when sending an
// approved estimate to despatch. "Assigned to Me" opens the owner's own
// despatch sheet instead of just notifying a salesman.
const List<String> _dummySalesmen = [
  'Assigned to Me',
  'Anoop Menon',
  'Ravi Kumar',
  'Sunitha Nair',
  'Vishnu Prasad',
];

class OwnerEstimateDetailsScreen extends StatefulWidget {
  const OwnerEstimateDetailsScreen({super.key, this.initialStatus});

  // Status of the estimate that was tapped to get here (e.g. 'Approved',
  // 'Pending', 'Rejected', 'Dispatched') — passed in from the Estimates
  // list so this screen opens already reflecting that status instead of
  // always defaulting to the dummy sample's Pending state. When it's
  // 'Approved' (or 'Dispatched'), the Send to Despatch section in the
  // bottom action bar shows immediately, same as before.
  final String? initialStatus;

  @override
  State<OwnerEstimateDetailsScreen> createState() => _OwnerEstimateDetailsScreenState();
}

class _OwnerEstimateDetailsScreenState extends State<OwnerEstimateDetailsScreen> {
  final _estimate = _DummyEstimate.sample();

  // Local mutable status so Approve/Reject can visibly flip the badge —
  // swap for cubit/bloc state once wired to the real API.
  late _DummyStatus _currentStatus = _statusFromLabel(widget.initialStatus) ?? _estimate.status;

  _DummyStatus? _statusFromLabel(String? label) {
    switch (label) {
      case 'Approved':
      case 'Dispatched':
      // Dispatched also lands on the Approved bucket here since this
      // dummy screen doesn't yet track a separate "already dispatched"
      // state — it still shows the Send to Despatch section.
        return _DummyStatus.approved;
      case 'Rejected':
        return _DummyStatus.rejected;
      case 'Pending':
        return _DummyStatus.pending;
      default:
        return null;
    }
  }

  // Tracks who approved/rejected it, and why (for reject), filled in
  // through the dialogs below.
  String? _approvedByAdmin;
  String? _rejectedByAdmin;
  String? _rejectionReason;

  // Set once the owner sends this estimate to despatch (either "Assigned
  // to Me" via OwnerDespatchSheetScreen, or notifying a salesman).
  DespatchInfo? _despatchInfo;

  // --- Discount / Payment / Balance ---
  //
  // Discount is now entered as a PERCENTAGE (e.g. "5" = 5% off the total)
  // rather than a flat rupee amount, since that's how the owner usually
  // thinks about it ("give him 5% off"). The rupee amount is derived from
  // the percentage automatically wherever it's shown.
  //
  // DUMMY DEFAULTS: both discount % and payment received start pre-filled
  // below (instead of null) purely so this screen shows a fully populated
  // UI on first look. Set either back to `null` to preview the empty
  // "Give Additional Discount" / "Add Payment" button states instead.
  double? _additionalDiscountPercent = 5; // dummy: 5% off
  double? _paymentReceived = 3000; // dummy: ₹3,000 already received

  // Rupee value of the discount, derived from the percentage above.
  double get _additionalDiscountAmount {
    final percent = _additionalDiscountPercent;
    if (percent == null) return 0;
    return _estimate.totalAmount * percent / 100;
  }

  // What's left to collect after discount and payments received.
  // Clamped at 0 so it never shows a negative balance if the owner
  // over-records a payment or discount.
  double get _balanceAmount {
    final discount = _additionalDiscountAmount;
    final paid = _paymentReceived ?? 0;
    final remaining = _estimate.totalAmount - discount - paid;
    return remaining < 0 ? 0 : remaining;
  }

  double get _incentiveTotal =>
      _estimate.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));

  Color _statusColor(_DummyStatus status) => status.color;

  String _buildShareText(NumberFormat currency, NumberFormat number) {
    final buffer = StringBuffer()
      ..writeln('Estimate ${_estimate.id}')
      ..writeln('Party Name: ${_estimate.partyName}')
      ..writeln('Party Address: ${_estimate.partyAddress}')
      ..writeln('Party Phone: ${_estimate.partyPhone}')
      ..writeln('Contractor: ${_estimate.contractorName}')
      ..writeln('Site Address: ${_estimate.siteAddress}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(_estimate.date)}')
      ..writeln('---');
    for (final item in _estimate.items) {
      buffer.writeln('${item.name} (${item.company}) x ${item.quantity.toStringAsFixed(0)} ${item.unit} = ${currency.format(item.amount)}');
    }
    buffer
      ..writeln('---')
      ..writeln('Handling Charge: ${_estimate.handlingCharge == null ? '-' : currency.format(_estimate.handlingCharge)}')
      ..writeln('Total: ${currency.format(_estimate.totalAmount)}');
    if (_additionalDiscountPercent != null) {
      buffer.writeln(
        'Additional Discount: ${_additionalDiscountPercent!.toStringAsFixed(0)}% (-${currency.format(_additionalDiscountAmount)})',
      );
    }
    if (_paymentReceived != null) {
      buffer.writeln('Payment Received: ${currency.format(_paymentReceived!)}');
    }
    buffer
      ..writeln('Balance Amount: ${currency.format(_balanceAmount)}')
      ..writeln('Type: ${_estimate.billType.label}')
      ..writeln('Status: ${_currentStatus.label}');
    if (_estimate.createdBySalesman) {
      buffer.writeln('Salesman: ${_estimate.salesmanName}');
    }
    // Total sqrft in the shared summary.
    buffer.writeln('Total Sqrft: ${number.format(_estimate.totalSqrft)}');
    if (_approvedByAdmin != null) {
      buffer.writeln('Approved by: $_approvedByAdmin');
    }
    // if (_rejectedByAdmin != null) {
    //   buffer.writeln('Rejected by: $_rejectedByAdmin');
    //   if (_rejectionReason != null && _rejectionReason!.isNotEmpty) {
    //     buffer.writeln('Reason: $_rejectionReason');
    //   }
    // }
    if (_despatchInfo != null) {
      buffer
        ..writeln('Despatched: ${DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate)}')
        ..writeln('Sent to: ${_despatchInfo!.assignedSalesman}');
      if (_despatchInfo!.driverName.isNotEmpty) {
        buffer.writeln('Driver: ${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})');
      }
    }
    return buffer.toString();
  }
  // Approve now just confirms, sets status, and returns to the home screen.
  Future<void> _showApproveDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Approve Estimate'),
          content: const Text('Are you sure you want to approve this estimate?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _approvedByAdmin = 'Approved';
        _rejectedByAdmin = null;
        _rejectionReason = null;
        _currentStatus = _DummyStatus.approved;
      });

      // TODO(owner-approval): replace this with the real API/cubit call,
      // e.g. context.read<OwnerEstimatesCubit>().approve(_estimate.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estimate approved')),
        );
        // Return to the home screen after approving.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
// Reject now only asks for a reason — no admin name required.
  Future<void> _showRejectDialog() async {
    final reasonController = TextEditingController(text: _rejectionReason ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Estimate'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Why is this estimate being rejected?',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reason is required';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(reasonController.text.trim());
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _rejectionReason = result;
        _rejectedByAdmin = null; // no admin name captured anymore
        _approvedByAdmin = null;
        _currentStatus = _DummyStatus.rejected;
      });

      // TODO(owner-rejection): replace this with the real API/cubit call,
      // e.g. context.read<OwnerEstimatesCubit>().reject(
      //   _estimate.id, reason: result,
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estimate rejected')),
        );
      }
    }
  }

  // Shared numeric-amount prompt used by the payment dialog — keeps the
  // validation/formatting logic in one place.
  Future<double?> _showAmountInputDialog({
    required String title,
    required String label,
    String? initialValue,
    String prefixText = '₹ ',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: label,
                prefixText: prefixText,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return null;
    return double.tryParse(result);
  }

  // Discount is captured as a PERCENTAGE (0-100). The dialog validates
  // the range and the rupee amount is derived automatically wherever
  // it's displayed (see _additionalDiscountAmount above).
  Future<void> _showAddDiscountDialog() async {
    final controller = TextEditingController(
      text: _additionalDiscountPercent?.toStringAsFixed(0) ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Additional Discount'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Discount %',
                suffixText: '%',
                helperText: 'Enter a value between 0 and 100',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Discount % is required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed < 0 || parsed > 100) {
                  return 'Enter a value between 0 and 100';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    final percent = double.tryParse(result);
    if (percent == null) return;

    setState(() => _additionalDiscountPercent = percent);

    // TODO(owner-discount): replace this with the real API/cubit call,
    // e.g. context.read<OwnerEstimatesCubit>().addDiscountPercent(_estimate.id, percent);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Additional discount added')),
      );
    }
  }

  Future<void> _showAddPaymentDialog() async {
    final amount = await _showAmountInputDialog(
      title: 'Payment Received',
      label: 'Amount Received',
      initialValue: _paymentReceived?.toStringAsFixed(0),
    );
    if (amount == null) return;

    setState(() => _paymentReceived = amount);

    // TODO(owner-payment): replace this with the real API/cubit call,
    // e.g. context.read<OwnerEstimatesCubit>().recordPayment(_estimate.id, amount);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );
    }
  }

  Future<void> _showSendToDespatchDialog() async {
    final currentSelection = _despatchInfo?.assignedSalesman ?? _estimate.salesmanName;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: Responsive.h(10)),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: Responsive.h(16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(18)),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                      SizedBox(width: Responsive.w(8)),
                      Text('Send to Despatch Sheet', style: AppTextStyles.h3()),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(4)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(18)),
                  child: Text(
                    'Choose who should handle despatch for ${_estimate.id}',
                    style: AppTextStyles.caption(),
                  ),
                ),
                SizedBox(height: Responsive.h(10)),
                const Divider(height: 1),
                ..._dummySalesmen.map((name) {
                  final isMe = name == 'Assigned to Me';
                  final isCurrent = name == currentSelection;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe
                          ? AppColors.primary.withOpacity(0.12)
                          : AppColors.surfaceAlt,
                      child: Icon(
                        isMe ? Icons.person_pin_circle_outlined : Icons.person_outline,
                        color: isMe ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      name,
                      style: AppTextStyles.bodyBold(),
                    ),
                    subtitle: isMe ? const Text('Opens your own despatch sheet') : null,
                    trailing: isCurrent
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(sheetContext).pop(name),
                  );
                }),
                SizedBox(height: Responsive.h(10)),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;

    if (result == 'Assigned to Me') {
      await _openOwnerDespatchSheet();
      return;
    }

    setState(() {
      _despatchInfo = DespatchInfo(
        driverName: '',
        driverPhone: '',
        despatchDate: DateTime.now(),
        assignedSalesman: result,
        deliveryAddress: _estimate.siteAddress,
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent to $result for despatch')),
      );
    }
  }

  // Pushes the owner's own, separate despatch sheet screen — distinct
  // from the salesman's DespatchSheetScreen (which is keyed off
  // EstimateModel). Passes this estimate's own data straight in.
  //
  // If this estimate was already despatched before (i.e. _despatchInfo
  // is already set with a driver_features name/phone, e.g. the owner re-opens
  // "Assigned to Me" a second time), that driver_features's name/phone is passed
  // in as initial values so the despatch sheet auto-fills them instead
  // of starting blank again.
  Future<void> _openOwnerDespatchSheet() async {
    final result = await Navigator.of(context).push<DespatchInfo>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(
          quotationId: _estimate.id,
          contractorName: _estimate.contractorName,
          phone: _estimate.phone,
          siteAddress: _estimate.siteAddress,
          initialDriverName: (_despatchInfo?.driverName.isNotEmpty ?? false)
              ? _despatchInfo!.driverName
              : null,
          initialDriverPhone: (_despatchInfo?.driverPhone.isNotEmpty ?? false)
              ? _despatchInfo!.driverPhone
              : null,
          items: _estimate.items
              .map((i) => OwnerDespatchItem(
            name: i.name,
            company: i.company,
            size: i.size,
            quantity: i.quantity,
            unit: i.unit,
          ))
              .toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() => _despatchInfo = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despatch sheet completed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Owner Estimate Details', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  // Top summary card — Estimate No. / Date, plus bill-type
                  // chip, matching the Owner Quotation Details layout.
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimate No.', style: AppTextStyles.caption()),
                            Text(_estimate.id, style: AppTextStyles.h3()),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Date', style: AppTextStyles.caption()),
                            Text(DateFormat('dd-MM-yyyy').format(_estimate.date), style: AppTextStyles.h3()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_estimate.billType.label, style: AppTextStyles.bodyBold()),
                      ),
                      SizedBox(width: Responsive.w(8)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(_currentStatus).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentStatus.label,
                          style: AppTextStyles.bodyBold(color: _statusColor(_currentStatus)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),

                  _DetailSection(
                    title: 'Party Details',
                    rows: [
                      _Row('Party Name', _estimate.partyName, icon: Icons.groups_2_outlined),
                      _Row('Party Address', _estimate.partyAddress, icon: Icons.location_on_outlined),
                      _Row('Phone Number', _estimate.partyPhone, icon: Icons.phone_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Contractor Details',
                    rows: [
                      _Row('Contractor Name', _estimate.contractorName, icon: Icons.engineering_outlined),
                      _Row('Contact No.', _estimate.phone.isEmpty ? '-' : _estimate.phone, icon: Icons.phone_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Submitted By',
                    rows: [
                      _Row(
                        _estimate.createdBySalesman ? 'Salesman' : 'Owner',
                        _estimate.createdBySalesman
                            ? (_estimate.salesmanName.isEmpty ? '-' : _estimate.salesmanName)
                            : 'Created by Owner',
                        icon: Icons.badge_outlined,
                      ),
                    ],
                  ),
                  if (_approvedByAdmin != null || _rejectedByAdmin != null) ...[
                    SizedBox(height: Responsive.h(14)),
                    _DetailSection(
                      title: 'Approval',
                      rows: [
                        if (_approvedByAdmin != null)
                          _Row('Approved By', _approvedByAdmin!, icon: Icons.check_circle_outline),
                        if (_rejectedByAdmin != null)
                          _Row('Rejected By', _rejectedByAdmin!, icon: Icons.cancel_outlined),
                        if (_rejectionReason != null && _rejectionReason!.isNotEmpty)
                          _Row('Reject Reason', _rejectionReason!, icon: Icons.info_outline),
                      ],
                    ),
                  ],
                  if (_despatchInfo != null) ...[
                    SizedBox(height: Responsive.h(14)),
                    _DetailSection(
                      title: 'Despatch',
                      rows: [
                        _Row('Sent To', _despatchInfo!.assignedSalesman, icon: Icons.local_shipping_outlined),
                        if (_despatchInfo!.driverName.isNotEmpty)
                          _Row(
                            'Driver',
                            _despatchInfo!.driverPhone.isEmpty
                                ? _despatchInfo!.driverName
                                : '${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})',
                            icon: Icons.badge_outlined,
                          ),
                        _Row(
                          'Despatch Date',
                          DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate),
                          icon: Icons.event_outlined,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: Responsive.h(20)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items', style: AppTextStyles.h3()),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Items: ${_estimate.items.length}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(12)),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
                        headingTextStyle: AppTextStyles.bodyBold(),
                        dataTextStyle: AppTextStyles.body(),
                        columnSpacing: 18,
                        columns: [
                          const DataColumn(label: Text('Sl.No')),
                          const DataColumn(label: Text('Item')),
                          const DataColumn(label: Text('Company')),
                          const DataColumn(label: Text('Size')),
                          const DataColumn(label: Text('Qty'), numeric: true),
                          const DataColumn(label: Text('Unit')),
                          const DataColumn(label: Text('MRP'), numeric: true),
                          const DataColumn(label: Text('Rate'), numeric: true),
                          const DataColumn(label: Text('Amount'), numeric: true),
                          // Incentive column only makes sense for
                          // salesman-submitted estimates.
                          if (_estimate.createdBySalesman)
                            const DataColumn(label: Text('Incentive'), numeric: true),
                        ],
                        rows: _estimate.items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(item.name)),
                            DataCell(Text(item.company.isEmpty ? '-' : item.company)),
                            DataCell(Text(item.size.isEmpty ? '-' : item.size)),
                            DataCell(Text(number.format(item.quantity))),
                            DataCell(Text(item.unit)),
                            DataCell(Text(number.format(item.mrp))),
                            DataCell(Text(number.format(item.rate))),
                            DataCell(Text(
                              currency.format(item.amount),
                              style: AppTextStyles.bodyBold(),
                            )),
                            if (_estimate.createdBySalesman)
                              DataCell(Text(
                                currency.format(_incentiveAmountFor(item)),
                                style: AppTextStyles.bodyBold(color: AppColors.success),
                              )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Items', style: AppTextStyles.body()),
                            Text('${_estimate.items.length}', style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MRP Total', style: AppTextStyles.body()),
                            Text(currency.format(_estimate.mrpTotal), style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Handling Charge', style: AppTextStyles.body()),
                            // Shows "-" when the salesman never added a
                            // handling charge, instead of a fabricated 0/₹0.
                            Text(
                              _estimate.handlingCharge == null
                                  ? '-'
                                  : currency.format(_estimate.handlingCharge!),
                              style: AppTextStyles.body(),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        // Total Sqrft also shown in the bottom summary.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Sqrft', style: AppTextStyles.body()),
                            Text(number.format(_estimate.totalSqrft), style: AppTextStyles.body()),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTextStyles.h3()),
                            Text(currency.format(_estimate.totalAmount), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                        SizedBox(height: Responsive.h(12)),

                        // Additional Discount — entered as a %, shown here
                        // with both the percentage and the rupee amount it
                        // works out to. Dummy-populated (5%) by default;
                        // tap the edit icon to change it.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _additionalDiscountPercent == null
                                      ? 'Additional Discount'
                                      : 'Additional Discount (${_additionalDiscountPercent!.toStringAsFixed(0)}%)',
                                  style: AppTextStyles.body(),
                                ),
                                if (_additionalDiscountPercent != null) ...[
                                  SizedBox(width: Responsive.w(6)),
                                  InkWell(
                                    onTap: _showAddDiscountDialog,
                                    child: Icon(Icons.edit_outlined, size: 14, color: AppColors.textHint),
                                  ),
                                ],
                              ],
                            ),
                            _additionalDiscountPercent == null
                                ? TextButton.icon(
                              onPressed: _showAddDiscountDialog,
                              icon: const Icon(Icons.local_offer_outlined, size: 16),
                              label: const Text('Give Additional Discount'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                                : Text(
                              '- ${currency.format(_additionalDiscountAmount)}',
                              style: AppTextStyles.bodyBold(color: Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(10)),

                        // Payment Received — what the party has already
                        // paid against this estimate. Same add/edit
                        // pattern as the discount row above. Dummy-populated
                        // (₹3,000) by default.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Payment Received', style: AppTextStyles.body()),
                                if (_paymentReceived != null) ...[
                                  SizedBox(width: Responsive.w(6)),
                                  InkWell(
                                    onTap: _showAddPaymentDialog,
                                    child: Icon(Icons.edit_outlined, size: 14, color: AppColors.textHint),
                                  ),
                                ],
                              ],
                            ),
                            _paymentReceived == null
                                ? TextButton.icon(
                              onPressed: _showAddPaymentDialog,
                              icon: const Icon(Icons.payments_outlined, size: 16),
                              label: const Text('Add Payment'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                                : Text(
                              currency.format(_paymentReceived!),
                              style: AppTextStyles.bodyBold(color: AppColors.success),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Balance Amount — Total minus discount and
                        // payments received. Red while still owed, green
                        // once fully settled.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Balance Amount', style: AppTextStyles.h3()),
                            Text(
                              currency.format(_balanceAmount),
                              style: AppTextStyles.h2(
                                color: _balanceAmount > 0 ? Colors.red : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Incentive block — ONLY for salesman-submitted estimates.
                  // Owner-created estimates (_estimate.createdBySalesman ==
                  // false) never show this.
                  if (_estimate.createdBySalesman) ...[
                    SizedBox(height: Responsive.h(12)),
                    Container(
                      padding: EdgeInsets.all(Responsive.w(14)),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.percent, size: 18, color: AppColors.success),
                              SizedBox(width: Responsive.w(8)),
                              Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
                              SizedBox(width: Responsive.w(6)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_dummyIncentivePercent.toStringAsFixed(0)}% · dummy',
                                  style: AppTextStyles.caption(color: AppColors.success),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currency.format(_incentiveTotal),
                            style: AppTextStyles.h3(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
              child: Column(
                children: [
                  Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: () {
                          // Hand this estimate off to your edit flow (e.g.
                          // re-open the create/edit screen pre-filled).
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wire this up to your edit flow')),
                          );
                        },
                      ),
                      SizedBox(width: Responsive.w(10)),
                      _RoundIconButton(
                        icon: Icons.share_outlined,
                        tooltip: 'Share',
                        onPressed: () async {
                          // Swap for `Share.share(...)` (share_plus package)
                          // once it's added to pubspec.yaml.
                          await Clipboard.setData(ClipboardData(text: _buildShareText(currency, number)));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Estimate summary copied to clipboard')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(10)),
                  _buildActionBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom action area, driven by _currentStatus:
  // Pending  -> Reject / Approve
  // Approved -> Send to Despatch Sheet (owner despatch access, incl.
  //             "Assigned to Me" -> OwnerDespatchSheetScreen)
  // Rejected -> read-only "Rejected by X" indicator
  Widget _buildActionBar() {
    if (_currentStatus == _DummyStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showRejectDialog,
              child: const Text('Reject'),
            ),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: PrimaryButton(
              label: 'Approve',
              height: 48,
              onPressed: _showApproveDialog,
            ),
          ),
        ],
      );
    }

    if (_currentStatus == _DummyStatus.approved) {
      return PrimaryButton(
        label: _despatchInfo == null
            ? 'Send to Despatch Sheet'
            : 'Sent to ${_despatchInfo!.assignedSalesman}',
        height: 48,
        onPressed: _showSendToDespatchDialog,
      );
    }

    // Rejected — nothing actionable, just a read-only indicator.
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: null,
      child: Text('Rejected by ${_rejectedByAdmin ?? '-'}'),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _Row {
  final String label;
  final String value;
  final IconData? icon;
  _Row(this.label, this.value, {this.icon});
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
          SizedBox(height: Responsive.h(10)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                SizedBox(
                  width: r.icon != null ? 88 : 100,
                  child: Text(r.label, style: AppTextStyles.caption()),
                ),
                Expanded(
                  child: Text(
                    r.value.isEmpty ? '-' : r.value,
                    style: AppTextStyles.bodyBold(),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
