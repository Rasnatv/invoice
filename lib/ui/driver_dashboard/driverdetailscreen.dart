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
  // Signature capture is upload-only now (no draw pad) and optional — the
  // driver can mark a bill delivered with either, both, or neither
  // signature attached.
  File? _customerSigFile;
  File? _driverSigFile;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(child:Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Despatch Details', style: AppTextStyles.h6()),
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
            context.read<DriverDespatchDetailBloc>().add(const ClearDriverDespatchActionStatus());
          } else if (state.actionStatus == DriverDespatchActionStatus.failure) {
            AppSnackbar.error(state.actionMessage ?? 'Something went wrong');
            context.read<DriverDespatchDetailBloc>().add(const ClearDriverDespatchActionStatus());
          }
        },
        builder: (context, state) {
          if (state.status == DriverDespatchDetailStatus.initial ||
              (state.status == DriverDespatchDetailStatus.loading && state.dispatch == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DriverDespatchDetailStatus.failure && state.dispatch == null) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load despatch bill',
              onRetry: () => context
                  .read<DriverDespatchDetailBloc>()
                  .add(FetchDriverDespatchDetail(widget.billId)),
            );
          }

          final bill = state.dispatch!;
          final isActing = state.actionStatus == DriverDespatchActionStatus.inProgress;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<DriverDespatchDetailBloc>();
                bloc.add(RefreshDriverDespatchDetail(widget.billId));
                await bloc.stream.firstWhere((s) =>
                s.status == DriverDespatchDetailStatus.success ||
                    s.status == DriverDespatchDetailStatus.failure);
              },
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  _StatusBanner(bill: bill),
                  SizedBox(height: Responsive.h(16)),
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _infoRow('DS Number', bill.dsNumber),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Ref. No.', bill.refNo),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Party Name', bill.partyName),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Contact Number', bill.contactNumber),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Delivery Address', bill.deliveryAddress),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Salesman', bill.salesmanName),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Despatched At', bill.despatchedAtDisplay),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Driver Name', bill.driverName),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Driver Contact No', bill.driverContact),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(18)),
                  Text('Items', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(10)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          color: AppColors.surfaceAlt,
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                          child: Row(
                            children: [
                              SizedBox(width: 24, child: Text('#', style: AppTextStyles.captionnew())),
                              Expanded(flex: 3, child: Text('Item', style: AppTextStyles.captionnew())),
                              Expanded(flex: 2, child: Text('Company', style: AppTextStyles.captionnew())),
                              Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
                              SizedBox(width: 44, child: Text('Box', style: AppTextStyles.captionnew())),
                              SizedBox(width: 44, child: Text('Pcs', style: AppTextStyles.captionnew())),
                            ],
                          ),
                        ),
                        for (var i = 0; i < bill.items.length; i++)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.border)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 24, child: Text(bill.items[i].slNo, style: AppTextStyles.body())),
                                Expanded(
                                  flex: 3,
                                  child: Text(bill.items[i].itemName,
                                      style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(bill.items[i].company,
                                      style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(bill.items[i].size,
                                      style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                ),
                                SizedBox(width: 44, child: Text(bill.items[i].boxes, style: AppTextStyles.body())),
                                SizedBox(width: 44, child: Text(bill.items[i].pieces, style: AppTextStyles.body())),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total', style: AppTextStyles.bodyBold()),
                      Text(
                        bill.grandTotalFormatted.isNotEmpty
                            ? bill.grandTotalFormatted
                            : bill.grandTotal.toStringAsFixed(2),
                        style: AppTextStyles.bodyBold(color: AppColors.primary)
                            .copyWith(fontSize: Responsive.sp(16)),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(22)),
                  _actionSection(context, bill, isActing),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
      ],
    );
  }

  /// Pending    -> single "Mark as In Transit" button.
  /// In transit -> two OPTIONAL signature upload blocks + "Mark as Delivered".
  /// Delivered  -> read-only signatures (server-hosted image URLs), captured at delivery time.
  /// Cancelled  -> nothing to do.
  Widget _actionSection(BuildContext context, DriverDespatchDetail bill, bool isActing) {
    if (bill.isCancelled) {
      return const SizedBox.shrink();
    }

    if (bill.isDelivered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signatures', style: AppTextStyles.h3()),
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
          Text('Capture Signatures', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(4)),
          Text('Optional — you can mark as delivered without these.',
              style: AppTextStyles.caption()),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing ? null : () => _confirmMarkDelivered(context, widget.billId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: isActing
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Mark as Delivered'),
            ),
          ),
        ],
      );
    }

    // pending
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isActing ? null : () => _confirmMarkInTransit(context, widget.billId),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: isActing
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.local_shipping_rounded, size: 18),
        label: const Text('Mark as In Transit'),
      ),
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
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(6)),
        if (file != null)
          _pickedImagePreview(file, onClear: onClearFile)
        else
          _uploadPlaceholder(onTap: onPick),
      ],
    );
  }

  Widget _uploadPlaceholder({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 100,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file_rounded, size: 22),
            SizedBox(height: Responsive.h(4)),
            Text('Tap to upload signature image', style: AppTextStyles.caption()),
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
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
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
  /// mark-delivered API now returns these as plain hosted image URLs
  /// (e.g. "https://.../storage/signatures/xxx.png") rather than base64
  /// data URIs, so we branch on that; base64 handling stays as a fallback
  /// for any older records that still carry a data URI.
  Widget _signatureImage(String label, String? sigData) {
    Widget content;
    if (sigData == null || sigData.isEmpty) {
      content = _placeholderBox('Not captured');
    } else if (sigData.startsWith('http://') || sigData.startsWith('https://')) {
      content = Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
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
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.memory(base64Decode(raw), fit: BoxFit.contain),
        );
      } catch (_) {
        content = _placeholderBox('Could not load signature');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(6)),
        content,
      ],
    );
  }

  Widget _placeholderBox(String text) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: AppTextStyles.caption()),
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

  /// Reads the picked file and returns it as a base64 data URI matching
  /// what the API expects (data:<mime>;base64,...).
  ///
  /// FIX: previously this always hardcoded `image/png` regardless of the
  /// file actually picked from the gallery. Most gallery images are JPEG,
  /// so the server received JPEG bytes mislabeled as PNG — the bytes
  /// decoded fine locally (Image.file sniffs real content) but broke once
  /// stored/served back as a URL (Image.network), which is why signatures
  /// appeared to "not show" after upload. We now detect the mime type from
  /// the file's actual extension.
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
      _ => 'image/jpeg', // gallery picks default to jpeg if extension is unclear
    };

    return 'data:$mime;base64,$base64Str';
  }

  void _confirmMarkInTransit(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as In Transit?'),
        content: const Text('This confirms you have picked up this despatch for delivery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<DriverDespatchDetailBloc>().add(MarkInTransitRequested(id));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Signatures are optional — whatever was (or wasn't) uploaded just gets
  /// sent straight through. No blocking validation here anymore.
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
      color = Colors.redAccent;
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
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(
        // withOpacity() is deprecated (precision loss) -> withValues(alpha: ...)
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5)),
            ),
          ),
        ],
      ),
    );
  }
}

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
            const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
            SizedBox(height: Responsive.h(10)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(14)),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}