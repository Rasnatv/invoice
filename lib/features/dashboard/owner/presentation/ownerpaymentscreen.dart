import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/estimate_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/estimate_model.dart';

/// Screen to record a payment against an estimate.
///
/// Shows Total Amount / Amount Paid (so far) / Balance, plus an input for
/// "amount paying now". On Save, returns the updated [EstimateModel] (with
/// amountPaid increased) to the caller via Navigator.pop, so the list
/// screen can update its state and re-show the new balance (or hide the
/// Pay Now button if balance becomes 0).
class OwnerPaymentScreen extends StatefulWidget {
  const OwnerPaymentScreen({super.key, required this.estimate});
  final EstimateModel estimate;

  @override
  State<OwnerPaymentScreen> createState() => _OwnerPaymentScreenState();
}

class _OwnerPaymentScreenState extends State<OwnerPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  late final NumberFormat _currency =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.parse(_amountCtrl.text.trim());
    final updated = widget.estimate.copyWith(
      amountPaid: widget.estimate.amountPaid + enteredAmount,
    );

    setState(() => _saving = true);

    // Return the updated estimate to the caller (OwnerEstimatesScreen),
    // which will replace the old estimate in its list and rebuild.
    // If you're saving to a backend, do that call here first and then pop.
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final e = widget.estimate;
    final balance = e.balance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Record Payment', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(16)),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(14)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.contractorName, style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(4)),
                      Text('Estimate No: ${e.id}', style: AppTextStyles.caption()),
                      SizedBox(height: Responsive.h(14)),
                      _SummaryRow(
                        label: 'Total Amount',
                        value: _currency.format(e.totalAmount),
                      ),
                      SizedBox(height: Responsive.h(8)),
                      _SummaryRow(
                        label: 'Amount Paid',
                        value: _currency.format(e.amountPaid),
                        valueColor: AppColors.primary,
                      ),
                      SizedBox(height: Responsive.h(8)),
                      const Divider(height: 1, color: AppColors.border),
                      SizedBox(height: Responsive.h(8)),
                      _SummaryRow(
                        label: 'Balance',
                        value: _currency.format(balance),
                        labelStyle: AppTextStyles.bodyBold(),
                        valueColor: Colors.red,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(20)),
                Text('Amount Paying Now', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(8)),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    hintText: 'Enter amount',
                  ),
                  validator: (val) {
                    final text = (val ?? '').trim();
                    if (text.isEmpty) return 'Enter an amount';
                    final amount = double.tryParse(text);
                    if (amount == null) return 'Enter a valid number';
                    if (amount <= 0) return 'Amount must be greater than 0';
                    if (amount > balance) {
                      return 'Amount cannot exceed balance (${_currency.format(balance)})';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.h(28)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : Text(
                      'Save',
                      style: AppTextStyles.bodyBold(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final valueStyle = bold
        ? AppTextStyles.bodyBold(color:   Colors.black)
        : AppTextStyles.body(color: Colors.red);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ?? AppTextStyles.caption()),
        Text(value, style: valueStyle),
      ],
    );
  }
}