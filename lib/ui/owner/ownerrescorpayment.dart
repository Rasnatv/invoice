// lib/presentation/owner/payments/record_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/paymentprovider.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/owner_models/paymentmodel.dart';

/// "Record Payment" screen.
///
/// Pass the estimate's id plus the display fields already on hand
/// (contractor/customer name, estimate number, total amount, amount
/// already paid) so this screen doesn't have to re-fetch anything just to
/// render its header card. On successful save it pops with `true` so the
/// caller (Payment History screen) can refresh.
class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({
    super.key,
    required this.estimateId,
    required this.contractorName,
    required this.estimateNumber,
    required this.totalAmount,
    required this.amountPaid,
  });

  final int estimateId;
  final String contractorName;
  final String estimateNumber;
  final double totalAmount;
  final double amountPaid;

  double get balance => totalAmount - amountPaid;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _paymentProvider = PaymentProvider();

  String? _selectedMethod;
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => _saving = true);

    final amount = double.parse(_amountCtrl.text.trim());
    final today = DateTime.now();
    final paymentDate =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final result = await _paymentProvider.addPayment(
      AddPaymentRequest(
        estimateId: widget.estimateId,
        amount: amount,
        paymentDate: paymentDate,
        paymentMethod: _selectedMethod!,
        notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Payment saved')),
      );
      Navigator.of(context).pop(true);
    } else if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Record Payment', style: AppTextStyles.h6()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(16)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(16)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.contractorName, style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(2)),
                      Text('Estimate No: ${widget.estimateNumber}',
                          style: AppTextStyles.caption()),
                      SizedBox(height: Responsive.h(12)),
                      _summaryRow('Total Amount',
                          CurrencyUtils.formatInr(widget.totalAmount)),
                      SizedBox(height: Responsive.h(6)),
                      _summaryRow('Amount Paid',
                          CurrencyUtils.formatInr(widget.amountPaid),
                          valueColor: AppColors.primary),
                      SizedBox(height: Responsive.h(8)),
                      const Divider(height: 1, color: AppColors.border),
                      SizedBox(height: Responsive.h(8)),
                      _summaryRow(
                        'Balance',
                        CurrencyUtils.formatInr(widget.balance),
                        labelBold: true,
                        valueColor: Colors.red,
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(20)),
                Text('Amount Paying Now *', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(8)),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(hintText: 'Enter amount'),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Amount is required';
                    final amount = double.tryParse(text);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    if (amount > widget.balance) {
                      return 'Amount cannot exceed balance (${CurrencyUtils.formatInr(widget.balance)})';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.h(20)),
                Text('Payment Method *', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(8)),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration:
                  const InputDecoration(hintText: 'Select payment method'),
                  items: PaymentMethod.all
                      .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(PaymentMethod.label(m)),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedMethod = v),
                ),
                SizedBox(height: Responsive.h(20)),
                Text('Note (Optional)', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(8)),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add any notes about this payment',
                  ),
                ),
                SizedBox(height: Responsive.h(28)),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text('Save Payment', style: AppTextStyles.bodyBold(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value, {
        bool labelBold = false,
        bool valueBold = false,
        Color? valueColor,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelBold
              ? AppTextStyles.bodyBold()
              : AppTextStyles.caption(),
        ),
        Text(
          value,
          style: valueBold
              ? AppTextStyles.bodyBold(color: Colors.black)
              : AppTextStyles.caption(color: Colors.green),
        ),
      ],
    );
  }
}