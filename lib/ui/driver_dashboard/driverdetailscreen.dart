import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../Apiprovider/driverdespatchprovider.dart';
import '../../bloc/driverbloc/driverdespatchdetail/driverdespatchdetail_bloc.dart';
import '../../bloc/driverbloc/driverdespatchdetail/driverdespatchdetail_event.dart';
import '../../bloc/driverbloc/driverdespatchdetail/driverdespatchdetail_state.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/drivermodels/driverdashboarddespatchdetailscreenmodel.dart';
import '../../widgets/appsnackbar.dart';

class DriverBillDetailScreen extends StatelessWidget {
  const DriverBillDetailScreen({super.key, required this.billId});

  final String billId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverDespatchDetailBloc(DriverDespatchProvider())
        ..add(FetchDriverDespatchDetail(billId)),
      child: _DriverBillDetailView(billId: billId),
    );
  }
}

class _DriverBillDetailView extends StatefulWidget {
  const _DriverBillDetailView({required this.billId});
  final String billId;

  @override
  State<_DriverBillDetailView> createState() => _DriverBillDetailViewState();
}

class _DriverBillDetailViewState extends State<_DriverBillDetailView> {
  // Signature capture is upload-only (no draw pad) and optional — the
  // driver can mark a bill delivered with either, both, or neither
  // signature attached.
  File? _customerSigFile;
  File? _driverSigFile;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Owner dispatch detail) ----------
        appBar: AppBar(
          title: Text('Despatch Details', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<DriverDespatchDetailBloc, DriverDespatchDetailState>(
          listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
          listener: (context, state) {
            if (state.actionStatus == DriverDespatchActionStatus.success) {
              AppSnackbar.success(state.actionMessage ?? 'Updated successfully');
              setState(() {
                _customerSigFile = null;
                _driverSigFile = null;
              });
              context
                  .read<DriverDespatchDetailBloc>()
                  .add(const ClearDriverDespatchActionStatus());
            } else if (state.actionStatus == DriverDespatchActionStatus.failure) {
              AppSnackbar.error(state.actionMessage ?? 'Something went wrong');
              context
                  .read<DriverDespatchDetailBloc>()
                  .add(const ClearDriverDespatchActionStatus());
            }
          },
          builder: (context, state) {
            if (state.status == DriverDespatchDetailStatus.initial ||
                (state.status == DriverDespatchDetailStatus.loading &&
                    state.dispatch == null)) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DriverDespatchDetailStatus.failure &&
                state.dispatch == null) {
              return _ErrorView(
                message: state.errorMessage ?? 'Failed to load despatch bill',
                onRetry: () => context
                    .read<DriverDespatchDetailBloc>()
                    .add(FetchDriverDespatchDetail(widget.billId)),
              );
            }

            final bill = state.dispatch!;
            final isActing = state.actionStatus == DriverDespatchActionStatus.inProgress;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final bloc = context.read<DriverDespatchDetailBloc>();
                bloc.add(RefreshDriverDespatchDetail(widget.billId));
                await bloc.stream.firstWhere((s) =>
                s.status == DriverDespatchDetailStatus.success ||
                    s.status == DriverDespatchDetailStatus.failure);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(20),
                  Responsive.h(14),
                  Responsive.w(20),
                  Responsive.h(24) + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _StatusBanner(bill: bill),
                  SizedBox(height: Responsive.h(14)),
                  _infoCard(bill),
                  SizedBox(height: Responsive.h(18)),
                  const _SectionHeader('Items'),
                  SizedBox(height: Responsive.h(10)),
                  _itemsTable(bill),
                  SizedBox(height: Responsive.h(14)),
                  _grandTotalCard(bill),
                  SizedBox(height: Responsive.h(20)),
                  _actionSection(context, bill, isActing),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- sections ----------

  Widget _infoCard(DriverDespatchDetail b) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow('DS Number', b.dsNumber),
          _infoRow('Ref. No.', b.refNo),
          _infoRow('Customer Name', b.partyName),
          _infoRow('Contact Number', b.contactNumber),
          _infoRow('Delivery Address', b.deliveryAddress),
          _infoRow('Salesman', b.salesmanName),
          _infoRow('Despatched At', b.despatchedAtDisplay),
          _infoRow('Driver Name', b.driverName),
          _infoRow('Driver Contact No', b.driverContact, isLast: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Responsive.h(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: AppTextStyles.caption(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold()),
          ),
        ],
      ),
    );
  }

  Widget _itemsTable(DriverDespatchDetail b) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
            verticalInside: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          // Fixed widths (not Flex) - the table can be wider than the
          // screen and scroll horizontally.
          columnWidths: const {
            0: FixedColumnWidth(32),  // #
            1: FixedColumnWidth(170), // Item
            2: FixedColumnWidth(170),
            3: FixedColumnWidth(170),
            4: FixedColumnWidth(70),
            5: FixedColumnWidth(70), // Pcs
            6: FixedColumnWidth(70),  // Qty (NEW)
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08)),
              children: [
                _headerCell('#'),
                _headerCell('Item'),
                _headerCell('Company'),
                _headerCell('Size'),
                _headerCell('Box', align: TextAlign.right),
                _headerCell('Pcs', align: TextAlign.right),
                _headerCell('Qty', align: TextAlign.right), // NEW
              ],
            ),
            for (var i = 0; i < b.items.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i.isEven ? Colors.white : AppColors.background,
                ),
                children: [
                  _dataCell(b.items[i].slNo.isEmpty ? '${i + 1}' : b.items[i].slNo),
                  _dataCell(b.items[i].itemName.isEmpty ? '-' : b.items[i].itemName),
                  _dataCell(b.items[i].company.isEmpty ? '-' : b.items[i].company),
                  _dataCell(b.items[i].size.isEmpty ? '-' : b.items[i].size),
                  _dataCell(b.items[i].boxes, align: TextAlign.right, bold: true),
                  _dataCell(b.items[i].pieces, align: TextAlign.right, bold: true),
                  _dataCell(
                    b.items[i].quantity.isEmpty ? '-' : b.items[i].quantity,
                    align: TextAlign.right,
                    bold: true,
                  ), // NEW
                ],
              ),
          ],
        ),
      ),
    );
  }
  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(9)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 3,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption(color: AppColors.textPrimary)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _dataCell(String text, {TextAlign align = TextAlign.left, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(8)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 3, // wraps up to 3 lines instead of overflowing
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: bold ? AppTextStyles.bodyBold() : AppTextStyles.body(),
      ),
    );
  }

  Widget _grandTotalCard(DriverDespatchDetail b) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Grand Total', style: AppTextStyles.bodyBold()),
          Text(
            b.grandTotalFormatted.isNotEmpty
                ? b.grandTotalFormatted
                : b.grandTotal.toStringAsFixed(2),
            style: AppTextStyles.amount(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Full-width primary button, same as the Owner dispatch detail screen.
  Widget _primaryButton({
    required String label,
    required bool loading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.h(48),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
        )
            : Text(label, style: AppTextStyles.bodyBold(color: Colors.white)),
      ),
    );
  }

  /// Pending    -> single "Mark as In Transit" button.
  /// In transit -> two OPTIONAL signature upload blocks + "Mark as Delivered".
  /// Delivered  -> read-only signatures (server-hosted image URLs).
  /// Cancelled  -> nothing to do.
  Widget _actionSection(
      BuildContext context, DriverDespatchDetail bill, bool isActing) {
    if (bill.isCancelled) {
      return const SizedBox.shrink();
    }

    if (bill.isDelivered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Signatures'),
          SizedBox(height: Responsive.h(10)),
          _signatureImage('Customer Signature', bill.customerSignatureBase64),
          SizedBox(height: Responsive.h(14)),
          _signatureImage('Driver Signature', bill.driverSignatureBase64),
        ],
      );
    }

    if (bill.isInTransit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Capture Signatures'),
          SizedBox(height: Responsive.h(4)),
          Text('Optional — you can mark as delivered without these.',
              style: AppTextStyles.caption(color: AppColors.textSecondary)),
          SizedBox(height: Responsive.h(10)),
          _signatureUploadBlock(
            label: 'Customer Signature (optional)',
            file: _customerSigFile,
            onPick: () => _pickSignatureImage(isCustomer: true),
            onClearFile: () => setState(() => _customerSigFile = null),
          ),
          SizedBox(height: Responsive.h(18)),
          _signatureUploadBlock(
            label: 'Driver Signature (optional)',
            file: _driverSigFile,
            onPick: () => _pickSignatureImage(isCustomer: false),
            onClearFile: () => setState(() => _driverSigFile = null),
          ),
          SizedBox(height: Responsive.h(18)),
          _primaryButton(
            label: 'Mark as Delivered',
            loading: isActing,
            onPressed: isActing ? null : () => _confirmMarkDelivered(context, widget.billId),
          ),
        ],
      );
    }

    // pending
    return _primaryButton(
      label: 'Mark as In Transit',
      loading: isActing,
      onPressed: isActing ? null : () => _confirmMarkInTransit(context, widget.billId),
    );
  }

  /// Upload-only signature block: shows a picked-image preview, or a tap
  /// target to pick one from the gallery. No drawing option.
  Widget _signatureUploadBlock({
    required String label,
    required File? file,
    required VoidCallback onPick,
    required VoidCallback onClearFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.textSecondary)),
        SizedBox(height: Responsive.h(6)),
        if (file != null)
          _pickedImagePreview(file, onClear: onClearFile)
        else
          _uploadPlaceholder(onTap: onPick),
      ],
    );
  }

  BoxDecoration get _signatureBoxDecoration => BoxDecoration(
    color: AppColors.background,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(14),
  );

  Widget _uploadPlaceholder({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 100,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: _signatureBoxDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_rounded, size: 22, color: AppColors.primary),
            SizedBox(height: Responsive.h(4)),
            Text('Tap to upload signature image',
                style: AppTextStyles.caption(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _pickedImagePreview(File file, {required VoidCallback onClear}) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          decoration: _signatureBoxDecoration,
          clipBehavior: Clip.antiAlias,
          child: Image.file(file, fit: BoxFit.contain),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onClear,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// Read-only render of a signature captured at delivery time. The
  /// mark-delivered API returns plain hosted image URLs; base64 handling
  /// stays as a fallback for older records that still carry a data URI.
  Widget _signatureImage(String label, String? sigData) {
    Widget content;

    if (sigData == null || sigData.isEmpty) {
      content = _placeholderBox('Not captured');
    } else if (sigData.startsWith('http://') || sigData.startsWith('https://')) {
      content = Container(
        height: 100,
        width: double.infinity,
        decoration: _signatureBoxDecoration,
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          sigData,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _placeholderBox('Could not load signature'),
        ),
      );
    } else {
      try {
        final raw = sigData.contains(',') ? sigData.split(',').last : sigData;
        content = Container(
          height: 100,
          width: double.infinity,
          decoration: _signatureBoxDecoration,
          clipBehavior: Clip.antiAlias,
          child: Image.memory(base64Decode(raw), fit: BoxFit.contain),
        );
      } catch (_) {
        content = _placeholderBox('Could not load signature');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.textSecondary)),
        SizedBox(height: Responsive.h(6)),
        content,
      ],
    );
  }

  Widget _placeholderBox(String text) {
    return Container(
      height: 100,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: _signatureBoxDecoration,
      child: Text(text, style: AppTextStyles.caption(color: AppColors.textSecondary)),
    );
  }

  // ---------- actions ----------

  Future<void> _pickSignatureImage({required bool isCustomer}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      if (isCustomer) {
        _customerSigFile = File(picked.path);
      } else {
        _driverSigFile = File(picked.path);
      }
    });
  }

  /// Reads the picked file and returns it as a base64 data URI with the
  /// mime type detected from the file's real extension (not hardcoded PNG),
  /// so JPEG gallery picks are stored/served correctly.
  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);

    final ext = file.path.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'png' => 'image/png',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };

    return 'data:$mime;base64,$base64Str';
  }

  Future<void> _confirmMarkInTransit(BuildContext context, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Mark as In Transit?',
      message: 'This confirms you have picked up this despatch for delivery.',
      confirmText: 'Confirm',
    );
    if (confirmed && context.mounted) {
      context.read<DriverDespatchDetailBloc>().add(MarkInTransitRequested(id));
    }
  }

  /// Signatures are optional — whatever was (or wasn't) uploaded just gets
  /// sent straight through. No blocking validation here.
  Future<void> _confirmMarkDelivered(BuildContext context, String id) async {
    final customerSig = await _fileToBase64(_customerSigFile);
    final driverSig = await _fileToBase64(_driverSigFile);

    if (!context.mounted) return;
    context.read<DriverDespatchDetailBloc>().add(MarkDeliveredRequested(
      id: id,
      customerSignatureBase64: customerSig,
      driverSignatureBase64: driverSig,
    ));
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(title, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.bill});
  final DriverDespatchDetail bill;

  @override
  Widget build(BuildContext context) {
    late Color color;
    late IconData icon;
    late String text;

    if (bill.isDelivered) {
      color = AppColors.info;
      icon = Icons.check_circle_rounded;
      text = 'Delivered';
    } else if (bill.isCancelled) {
      color = AppColors.error;
      icon = Icons.cancel_rounded;
      text = 'Cancelled';
    } else if (bill.isInTransit) {
      color = AppColors.primary;
      icon = Icons.local_shipping_rounded;
      text = bill.despatchedAtDisplay.isNotEmpty
          ? 'In transit since ${bill.despatchedAtDisplay}'
          : 'In transit';
    } else {
      color = AppColors.warning;
      icon = Icons.local_shipping_outlined;
      text = 'Pending pickup';
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyBold(color: color)),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ERROR VIEW
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
                color: AppColors.textSecondary.withValues(alpha: 0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
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