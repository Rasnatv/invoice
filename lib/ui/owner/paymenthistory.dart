import 'package:flutter/material.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/paymentprovider.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/owner_models/paymentmodel.dart';
import '../../widgets/appsnackbar.dart';
import 'ownerrescorpayment.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({
    super.key,
    required this.estimateId,
    this.contractorName,
    this.estimateNumber,
  });

  final int estimateId;
  final String? contractorName;
  final String? estimateNumber;

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  static const _red = Color(0xFFDC2626);
  static const _amber = Color(0xFFF59E0B);

  final _paymentProvider = PaymentProvider();

  bool _loading = true;
  bool _changed = false; // a payment was recorded -> tell the previous screen
  String? _error;
  PaymentDetailsData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _paymentProvider.getPaymentDetails(widget.estimateId);

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _data = result.data;
      } else {
        _error = result.errorMessage ?? 'Failed to load payment history.';
      }
    });
  }

  Future<void> _openRecordPayment() async {
    final data = _data;
    if (data == null) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecordPaymentScreen(
          estimateId: widget.estimateId,
          contractorName: data.estimate.customerName.isNotEmpty
              ? data.estimate.customerName
              : (widget.contractorName ?? ''),
          estimateNumber: data.estimate.estimateNumber.isNotEmpty
              ? data.estimate.estimateNumber
              : (widget.estimateNumber ?? ''),
          totalAmount: data.financialSummary.payableAmount,
          amountPaid: data.paymentSummary.totalPaid,
        ),
      ),
    );

    if (saved == true) {
      _changed = true;
      _load();
    }
  }

  bool _hasBalance(PaymentDetailsData d) =>
      (d.paymentSummary.balanceAmount * 100).round() > 0;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return _red;
      case 'despatched':
        return AppColors.primary;
      default:
        return _amber;
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final data = _data;

    return NetworkAwareWrapper(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          Navigator.of(context).pop(_changed);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text('Payment History', style: AppTextStyles.h6()),
          ),
          body: SafeArea(child: _buildBody(data)),
          bottomNavigationBar: (data != null && _hasBalance(data))
              ? SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(Responsive.w(20),
                  Responsive.h(10), Responsive.w(20), Responsive.h(12)),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _openRecordPayment,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Record Payment',
                      style:
                      AppTextStyles.bodyBold(color: Colors.white)),
                ),
              ),
            ),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildBody(PaymentDetailsData? data) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: AppColors.textSecondary.withOpacity(0.5), size: 38),
              SizedBox(height: Responsive.h(10)),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle()),
              SizedBox(height: Responsive.h(10)),
              TextButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    if (data == null) return const SizedBox.shrink();

    final fin = data.financialSummary;
    final pay = data.paymentSummary;
    final est = data.estimate;
    final hasBalance = _hasBalance(data);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(Responsive.w(20), Responsive.h(14),
            Responsive.w(20), Responsive.h(24)),
        children: [
          // ---------- Estimate / customer ----------
          _ListCard(
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
                            est.estimateNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            est.customerName,
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
                      label: _capitalize(est.status),
                      color: _statusColor(est.status),
                    ),
                  ],
                ),
                if (est.customerPhone.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(10)),
                  _InfoRow(
                      icon: Icons.phone_outlined, text: est.customerPhone),
                ],
                if (est.date.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(6)),
                  _InfoRow(
                      icon: Icons.calendar_today_rounded, text: est.date),
                ],
                SizedBox(height: Responsive.h(12)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(10)),

                // Full-width rows so long amounts never wrap
                _AmountRow(
                  label: 'Total Amount',
                  value: CurrencyUtils.formatInr(fin.payableAmount),
                  valueStyle: AppTextStyles.amount(color: AppColors.primary),
                ),
                SizedBox(height: Responsive.h(6)),
                _AmountRow(
                  label: 'Paid Amount',
                  value: CurrencyUtils.formatInr(pay.totalPaid),
                  valueStyle:
                  AppTextStyles.bodyBold(color: AppColors.success),
                ),
                SizedBox(height: Responsive.h(12)),
                _BalanceBar(
                  amountText: CurrencyUtils.formatInr(pay.balanceAmount),
                  paid: !hasBalance,
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(12)),

          // ---------- Payment details (breakdown) ----------
          _ListCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Payment Details',
                          style: AppTextStyles.bodyBold()),
                    ),
                    _StatusPill(
                      label: _capitalize(pay.balanceStatus),
                      color: pay.isFullyPaid
                          ? AppColors.success
                          : (pay.balanceStatus == 'unpaid' ? _red : _amber),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                _detailRow('Subtotal', CurrencyUtils.formatInr(fin.subtotal)),
                _detailRow('Handling Charge',
                    CurrencyUtils.formatInr(fin.handlingCharge)),
                _detailRow(
                    'Grand Total', CurrencyUtils.formatInr(fin.grandTotal)),
                _detailRow('Discount',
                    '- ${CurrencyUtils.formatInr(fin.discountAmount)}',
                    valueColor: _red),
                SizedBox(height: Responsive.h(6)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(6)),
                _detailRow('Amount After Discount',
                    CurrencyUtils.formatInr(fin.payableAmount),
                    bold: true),
                _detailRow(
                    'Total Paid', CurrencyUtils.formatInr(pay.totalPaid),
                    valueColor: AppColors.success),
                _detailRow(
                    'Balance', CurrencyUtils.formatInr(pay.balanceAmount),
                    bold: true,
                    valueColor: hasBalance ? _red : AppColors.success),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(16)),

          // ---------- Payments list ----------
          Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Text(
              'Payments (${data.payments.length})',
              style: AppTextStyles.bodyBold(),
            ),
          ),
          if (data.payments.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: Responsive.h(30)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 44,
                        color: AppColors.textSecondary.withOpacity(0.4)),
                    SizedBox(height: Responsive.h(10)),
                    Text('No payments recorded yet',
                        style: AppTextStyles.subtitle()),
                  ],
                ),
              ),
            )
          else
            ...List.generate(data.payments.length, (i) {
              final payment = data.payments[i];
              final number = data.payments.length - i;
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(10)),
                child: _PaymentTile(payment: payment, number: number),
              );
            }),
        ],
      ),
    );
  }

  /// Label on the left at natural width, value fills the rest and is
  /// right-aligned. Very long amounts scale down instead of squeezing the label.
  Widget _detailRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    final color = valueColor ?? AppColors.textPrimary;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(3)),
      child: Row(
        children: [
          Text(
            label,
            maxLines: 1,
            style: bold
                ? AppTextStyles.bodyBold()
                : AppTextStyles.caption(color: AppColors.textSecondary),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: _AmountText(
              value,
              style: bold
                  ? AppTextStyles.bodyBold(color: color)
                  : AppTextStyles.caption(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PAYMENT TILE
// =====================================================================

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.number});

  final PaymentItem payment;
  final int number;

  IconData get _icon {
    switch (payment.paymentMethod) {
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.cheque:
        return Icons.receipt_long_outlined;
      case PaymentMethod.online:
        return Icons.language_outlined;
      case PaymentMethod.credit:
        return Icons.credit_card_outlined;
      case PaymentMethod.cash:
      default:
        return Icons.attach_money_outlined;
    }
  }

  Color get _chipColor {
    switch (payment.paymentMethod) {
      case PaymentMethod.bankTransfer:
        return Colors.purple;
      case PaymentMethod.cheque:
        return Colors.blueGrey;
      case PaymentMethod.online:
        return Colors.blue;
      case PaymentMethod.credit:
        return const Color(0xFFF59E0B);
      case PaymentMethod.cash:
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      if (payment.createdBy.isNotEmpty) 'Recorded by ${payment.createdBy}',
      if (payment.createdAt.isNotEmpty) payment.createdAt,
    ].join(' • ');

    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: number tile, method + date, method pill ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('#$number',
                      style:
                      AppTextStyles.bodyBold(color: AppColors.primary)),
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_icon, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(6)),
                        Expanded(
                          child: Text(
                            PaymentMethod.label(payment.paymentMethod),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      payment.paymentDate,
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
                label: PaymentMethod.label(payment.paymentMethod),
                color: _chipColor,
              ),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- amount on its own row: never squeezes the details ----
          _AmountRow(
            label: 'Amount',
            value: CurrencyUtils.formatInr(payment.amount),
            valueStyle: AppTextStyles.amount(color: AppColors.primary),
          ),

          if (payment.hasReference) ...[
            SizedBox(height: Responsive.h(8)),
            _InfoRow(
                icon: Icons.tag_rounded,
                text: 'Ref: ${payment.paymentReference}'),
          ],
          if (payment.notes.isNotEmpty) ...[
            SizedBox(height: Responsive.h(6)),
            _InfoRow(
                icon: Icons.sticky_note_2_outlined,
                text: 'Note: ${payment.notes}'),
          ],
          if (meta.isNotEmpty) ...[
            SizedBox(height: Responsive.h(6)),
            _InfoRow(icon: Icons.person_outline_rounded, text: meta),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
// SHARED LOOK (same as the estimates screen)
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
            maxLines: 2,
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

class _BalanceBar extends StatelessWidget {
  const _BalanceBar({required this.amountText, required this.paid});
  final String amountText;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final color = paid ? AppColors.success : const Color(0xFFDC2626);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(8)),
      decoration: BoxDecoration(
        color: color.withOpacity(paid ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            paid
                ? Icons.check_circle_outline_rounded
                : Icons.account_balance_wallet_outlined,
            size: 16,
            color: color,
          ),
          SizedBox(width: Responsive.w(6)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paid ? 'Fully paid' : 'Balance due',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: Responsive.sp(10),
                    color: AppColors.textSecondary,
                  ),
                ),
                _AmountText(
                  amountText,
                  alignment: Alignment.centerLeft,
                  style: AppTextStyles.bodyBold(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// label on the left, amount on the right (scales down for huge numbers).
class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    required this.valueStyle,
  });
  final String label;
  final String value;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.caption(color: AppColors.textSecondary)),
        SizedBox(width: Responsive.w(10)),
        Expanded(child: _AmountText(value, style: valueStyle)),
      ],
    );
  }
}

/// Single-line text that shrinks instead of wrapping or overflowing.
class _AmountText extends StatelessWidget {
  const _AmountText(
      this.text, {
        required this.style,
        this.alignment = Alignment.centerRight,
      });
  final String text;
  final TextStyle style;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(text, maxLines: 1, softWrap: false, style: style),
    );
  }
}