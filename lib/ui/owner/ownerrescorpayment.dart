
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputType;
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/paymentprovider.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/validator/validationfile.dart';
import '../../models/owner_models/paymentmodel.dart';
import '../../widgets/appsnackbar.dart';

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
  static const _red = Color(0xFFDC2626);

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _paymentProvider = PaymentProvider();

  String? _selectedMethod;
  bool _saving = false;

  int _paise(double v) => (v * 100).round();
  bool get _fullyPaid => _paise(widget.balance) <= 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _fillFullBalance() {
    _amountCtrl.text = widget.balance.toStringAsFixed(2);
    _amountCtrl.selection =
        TextSelection.collapsed(offset: _amountCtrl.text.length);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final amount = double.parse(_amountCtrl.text.trim());
    final today = DateTime.now();
    final paymentDate = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final note = _noteCtrl.text.trim();

    final result = await _paymentProvider.addPayment(
      AddPaymentRequest(
        estimateId: widget.estimateId,
        amount: amount,
        paymentDate: paymentDate,
        paymentMethod: _selectedMethod!,
        notes: note.isEmpty ? null : note,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (result.success) {
      AppSnackbar.success(result.message ?? 'Payment saved');
      Navigator.of(context).pop(true);
    } else {
      AppSnackbar.error(
          result.errorMessage ?? 'Could not save payment. Please try again.');
    }
  }

  // Same look as _SearchField on the estimates screen
  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  InputDecoration _decoration(String hint, {String? prefixText}) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: AppTextStyles.body(),
      hintStyle: AppTextStyles.body(color: AppColors.textHint),
      contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(13)),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      disabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.primary),
      errorBorder: _border(_red),
      focusedErrorBorder: _border(_red),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: PopScope(
        canPop: !_saving,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(' Payments', style: AppTextStyles.h6()),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(Responsive.w(20),
                    Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      SizedBox(height: Responsive.h(20)),

                      // ---- amount ----
                      Row(
                        children: [
                          Expanded(
                            child: Text('Amount Paying Now *',
                                style: AppTextStyles.bodyBold()),
                          ),
                          if (!_fullyPaid)
                            _FilterChip(
                              label: 'Pay full balance',
                              selected: false,
                              onTap: _saving ? () {} : _fillFullBalance,
                            ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(8)),
                      TextFormField(
                        controller: _amountCtrl,
                        enabled: !_fullyPaid && !_saving,
                        style: AppTextStyles.body(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        // max 15 digits before the decimal point, 2 after
                        inputFormatters: DValidator.paymentAmount,
                        decoration:
                        _decoration('Enter amount', prefixText: '₹ '),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Amount is required';
                          final amount = double.tryParse(text);
                          if (amount == null || _paise(amount) <= 0) {
                            return 'Enter a valid amount';
                          }
                          if (_paise(amount) > _paise(widget.balance)) {
                            return 'Amount cannot exceed balance '
                                '(${CurrencyUtils.formatInr(widget.balance)})';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.h(20)),

                      // ---- method ----
                      Text('Payment Method *',
                          style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(8)),
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(14),
                        dropdownColor: Colors.white,
                        decoration: _decoration('Select payment method'),
                        style: AppTextStyles.body(),
                        items: PaymentMethod.all
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(PaymentMethod.label(m)),
                        ))
                            .toList(),
                        onChanged: _fullyPaid || _saving
                            ? null
                            : (v) => setState(() => _selectedMethod = v),
                        validator: (v) =>
                        v == null ? 'Please select a payment method' : null,
                      ),
                      SizedBox(height: Responsive.h(20)),

                      // ---- note ----
                      Text('Note (Optional)', style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(8)),
                      TextFormField(
                        controller: _noteCtrl,
                        enabled: !_fullyPaid && !_saving,
                        maxLines: 3,
                        style: AppTextStyles.body(),
                        textCapitalization: TextCapitalization.sentences,
                        decoration:
                        _decoration('Add any notes about this payment'),
                      ),
                      SizedBox(height: Responsive.h(28)),

                      // ---- save (same style as "Pay Now") ----
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_saving || _fullyPaid) ? null : _save,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.5),
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _saving
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : Text('Save Payment',
                              style: AppTextStyles.bodyBold(
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- summary card: same structure as _OwnerEstimateCard ----------
  Widget _buildSummaryCard() {
    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.description_outlined),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.estimateNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      widget.contractorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (_fullyPaid) ...[
                SizedBox(width: Responsive.w(8)),
                const _StatusPill(label: 'Paid', color: AppColors.success),
              ],
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount',
                  style:
                  AppTextStyles.caption(color: AppColors.textSecondary)),
              Text(
                CurrencyUtils.formatInr(widget.totalAmount),
                style: AppTextStyles.amount(color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(6)),

          // paid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount Paid',
                  style:
                  AppTextStyles.caption(color: AppColors.textSecondary)),
              Text(
                CurrencyUtils.formatInr(widget.amountPaid),
                style: AppTextStyles.bodyBold(color: AppColors.success),
              ),
            ],
          ),

          // balance bar (same as _BalanceBar, without the button)
          if (!_fullyPaid) ...[
            SizedBox(height: Responsive.h(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(10), vertical: Responsive.h(8)),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 16, color: _red),
                  SizedBox(width: Responsive.w(6)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance due',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: Responsive.sp(10),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyUtils.formatInr(widget.balance),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold(color: _red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
// Shared look: copied from the estimates screen.
// Better: move these into widgets/ and import them in both screens.
// =====================================================================

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12), vertical: Responsive.h(6)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: Responsive.sp(11.5),
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}