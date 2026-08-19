// lib/presentation/owner/payments/payment_history_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/paymentprovider.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/owner_models/paymentmodel.dart';
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
  final _paymentProvider = PaymentProvider();

  bool _loading = true;
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
          totalAmount: data.financialSummary.grandTotal,
          amountPaid: data.paymentSummary.totalPaid,
        ),
      ),
    );

    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final data = _data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Payment History', style: AppTextStyles.h6()),
        actions: [
          if (data != null)
            Padding(
              padding: EdgeInsets.only(right: Responsive.w(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Paid: ${CurrencyUtils.formatInr(data.paymentSummary.totalPaid)}',
                    style: AppTextStyles.caption(color: Colors.white),
                  ),
                  Text(
                    '${data.payments.length} payment${data.payments.length == 1 ? '' : 's'}',
                    style: AppTextStyles.caption(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(child: _buildBody(data)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: data == null
          ? null
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'share_payment_history',
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon')),
              );
            },
            child: const Icon(Icons.share_outlined),
          ),
          SizedBox(height: Responsive.h(12)),
          FloatingActionButton(
            heroTag: 'record_payment',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: data.paymentSummary.isFullyPaid
                ? null
                : _openRecordPayment,
            child: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PaymentDetailsData? data) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(16), Responsive.h(16), Responsive.w(16), Responsive.h(100)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimate #${data.estimate.estimateNumber}',
                        style: AppTextStyles.bodyBold()),
                    Text(data.estimate.customerName,
                        style: AppTextStyles.bodyBold(color: AppColors.primary)),
                  ],
                ),
                SizedBox(height: Responsive.h(12)),
                Row(
                  children: [
                    _summaryColumn('Total Amount',
                        CurrencyUtils.formatInr(data.financialSummary.grandTotal)),
                    _summaryColumn('Paid Amount',
                        CurrencyUtils.formatInr(data.paymentSummary.totalPaid),
                        color: AppColors.primary),
                    _summaryColumn('Balance',
                        CurrencyUtils.formatInr(data.paymentSummary.balanceAmount),
                        color: data.paymentSummary.balanceAmount > 0
                            ? Colors.red
                            : AppColors.success),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(16)),
          if (data.payments.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: Responsive.h(40)),
              child: Center(
                child: Text('No payments recorded yet', style: AppTextStyles.subtitle()),
              ),
            )
          else
            ...List.generate(data.payments.length, (i) {
              // Newest first, numbered from the total count down to 1
              // (matches "#2" / "#1" style in the design).
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

  Widget _summaryColumn(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(4)),
          Text(value, style: AppTextStyles.bodyBold(color: Colors.black)),
        ],
      ),
    );
  }
}

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
        return Colors.orange;
      case PaymentMethod.cash:
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text('#$number',
                style: AppTextStyles.bodyBold(color: AppColors.primary)),
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
                    Text(PaymentMethod.label(payment.paymentMethod),
                        style: AppTextStyles.bodyBold()),
                  ],
                ),
                SizedBox(height: Responsive.h(4)),
                Text(payment.paymentDate, style: AppTextStyles.caption()),
                if (payment.notes.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(2)),
                  Text(payment.notes, style: AppTextStyles.caption()),
                ],
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatInr(payment.amount),
                style: AppTextStyles.bodyBold(color: AppColors.primary),
              ),
              SizedBox(height: Responsive.h(6)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _chipColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  PaymentMethod.label(payment.paymentMethod),
                  style: AppTextStyles.caption(color: _chipColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}