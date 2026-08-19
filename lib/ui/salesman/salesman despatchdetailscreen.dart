import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail/ownerdespatchdetail_bloc.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail/ownerdespatchdetail_event.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail/ownerdespatchdetail_state.dart';

import '../../models/owner_models/owner_despatchdetailmodel.dart';
import '../../widgets/signaturecontroller.dart';

/// Salesman version of the dispatch bill detail screen.
///
/// Deliberately reuses [DispatchDetailBloc] / [DispatchProvider] / events /
/// states from the owner flow — same auth token, same API, same shape of
/// data, same mark-in-transit / mark-delivered actions.
class SalesmanDispatchDetailScreen extends StatelessWidget {
  const SalesmanDispatchDetailScreen({super.key, required this.dispatchId});

  final String dispatchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DispatchDetailBloc(DispatchProvider())..add(FetchDispatchDetail(dispatchId)),
      child: _SalesmanDispatchDetailView(dispatchId: dispatchId),
    );
  }
}

class _SalesmanDispatchDetailView extends StatefulWidget {
  const _SalesmanDispatchDetailView({required this.dispatchId});
  final String dispatchId;

  @override
  State<_SalesmanDispatchDetailView> createState() => _SalesmanDispatchDetailViewState();
}

class _SalesmanDispatchDetailViewState extends State<_SalesmanDispatchDetailView> {
  final _customerSigCtrl = SignaturePadController();
  final _driverSigCtrl = SignaturePadController();

  // Picked image files, used as an alternative to drawing on the pad.
  File? _customerSigFile;
  File? _driverSigFile;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Dispatch Details', style: AppTextStyles.h6())),
      body: BlocConsumer<DispatchDetailBloc, DispatchDetailState>(
        listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == DispatchActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionMessage ?? 'Updated successfully')),
            );
            _customerSigCtrl.clear();
            _driverSigCtrl.clear();
            setState(() {
              _customerSigFile = null;
              _driverSigFile = null;
            });
            context.read<DispatchDetailBloc>().add(const ClearDispatchActionStatus());
          } else if (state.actionStatus == DispatchActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage ?? 'Something went wrong'),
                backgroundColor: Colors.redAccent,
              ),
            );
            context.read<DispatchDetailBloc>().add(const ClearDispatchActionStatus());
          }
        },
        builder: (context, state) {
          if (state.status == DispatchDetailStatus.initial ||
              state.status == DispatchDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DispatchDetailStatus.failure && state.dispatch == null) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load dispatch bill',
              onRetry: () => context
                  .read<DispatchDetailBloc>()
                  .add(FetchDispatchDetail(widget.dispatchId)),
            );
          }

          final dispatch = state.dispatch!;
          final isActing = state.actionStatus == DispatchActionStatus.inProgress;

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<DispatchDetailBloc>();
              bloc.add(RefreshDispatchDetail(widget.dispatchId));
              await bloc.stream.firstWhere(
                    (s) => s.status == DispatchDetailStatus.success || s.status == DispatchDetailStatus.failure,
              );
            },
            child: ListView(
              padding: EdgeInsets.all(Responsive.w(18)),
              children: [
                _StatusBanner(dispatch: dispatch),
                SizedBox(height: Responsive.h(16)),
                _infoCard(dispatch),
                SizedBox(height: Responsive.h(18)),
                Text('Items', style: AppTextStyles.h3()),
                SizedBox(height: Responsive.h(10)),
                _itemsTable(dispatch),
                SizedBox(height: Responsive.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: AppTextStyles.bodyBold()),
                    Text(
                      _currency(dispatch.grandTotal),
                      style: AppTextStyles.bodyBold(color: AppColors.primary)
                          .copyWith(fontSize: Responsive.sp(16)),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(22)),
                _actionSection(context, dispatch, isActing),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- sections ----------

  Widget _infoCard(DispatchDetail d) {
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow('DS Number', d.dsNumber),
          _infoRow('Ref. No.', d.refNo),
          _infoRow('Party Name', d.partyName),
          _infoRow('Contact Number', d.contactNumber),
          _infoRow('Delivery Address', d.deliveryAddress),
          _infoRow('Driver Name', d.driverName),
          _infoRow('Vehicle Number', d.vehicleNumber),
          if (d.despatchedAt != null) _infoRow('Despatched At', dateFmt.format(d.despatchedAt!)),
          if (d.deliveryNotes.isNotEmpty) _infoRow('Delivery Notes', d.deliveryNotes),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
        ],
      ),
    );
  }

  Widget _itemsTable(DispatchDetail d) {
    return Container(
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
                Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
                SizedBox(width: 44, child: Text('Box', style: AppTextStyles.captionnew())),
                SizedBox(width: 44, child: Text('Pcs', style: AppTextStyles.captionnew())),
              ],
            ),
          ),
          for (var i = 0; i < d.items.length; i++)
            Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.body())),
                  Expanded(
                    flex: 3,
                    child: Text(d.items[i].productName,
                        style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(d.items[i].productSize,
                        style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 44, child: Text(d.items[i].boxes.toStringAsFixed(0), style: AppTextStyles.body())),
                  SizedBox(width: 44, child: Text(d.items[i].pieces.toStringAsFixed(0), style: AppTextStyles.body())),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Pending -> "Mark as In Transit" button.
  /// In transit -> two signature capture blocks (draw OR upload) + "Mark as Delivered".
  /// Delivered -> read-only signatures, no actions.
  Widget _actionSection(BuildContext context, DispatchDetail d, bool isActing) {
    if (d.isDelivered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signatures', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(10)),
          _signatureImage('Customer Signature', d.customerSignature),
          SizedBox(height: Responsive.h(14)),
          _signatureImage('Driver Signature', d.driverSignature),
        ],
      );
    }

    if (d.isInTransit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Capture Signatures', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(10)),
          _signatureCaptureBlock(
            label: 'Customer Signature',
            controller: _customerSigCtrl,
            file: _customerSigFile,
            onPick: () => _pickSignatureImage(isCustomer: true),
            onClearFile: () => setState(() => _customerSigFile = null),
          ),
          SizedBox(height: Responsive.h(18)),
          _signatureCaptureBlock(
            label: 'Driver Signature',
            controller: _driverSigCtrl,
            file: _driverSigFile,
            onPick: () => _pickSignatureImage(isCustomer: false),
            onClearFile: () => setState(() => _driverSigFile = null),
          ),
          SizedBox(height: Responsive.h(18)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isActing ? null : () => _confirmMarkDelivered(context, d.id),
              child: isActing
                  ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Mark as Delivered'),
            ),
          ),
        ],
      );
    }

    // pending
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActing ? null : () => _confirmMarkInTransit(context, d.id),
        child: isActing
            ? const SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text('Mark as In Transit'),
      ),
    );
  }

  /// Either the drawing pad, or a preview of the picked image — plus a
  /// button to switch to "upload instead" / "draw instead".
  Widget _signatureCaptureBlock({
    required String label,
    required SignaturePadController controller,
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
          _pickedImagePreview(file, onClear: () {
            onClearFile();
            controller.clear();
          })
        else
          SignaturePad(controller: controller),
        SizedBox(height: Responsive.h(6)),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              if (file != null) {
                onClearFile(); // switch back to drawing
              } else {
                onPick();
              }
            },
            icon: Icon(
              file != null ? Icons.edit_rounded : Icons.upload_file_rounded,
              size: 18,
            ),
            label: Text(file != null ? 'Draw signature instead' : 'Upload signature image instead'),
          ),
        ),
      ],
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

  Widget _signatureImage(String label, String? base64Data) {
    Widget content;
    if (base64Data == null || base64Data.isEmpty) {
      content = Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('Not captured', style: AppTextStyles.caption()),
      );
    } else {
      try {
        final raw = base64Data.contains(',') ? base64Data.split(',').last : base64Data;
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
        content = Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Could not load signature', style: AppTextStyles.caption()),
        );
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
  /// what the API already accepts (data:image/png;base64,...).
  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    return 'data:image/png;base64,$base64Str';
  }

  void _confirmMarkInTransit(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Mark as In Transit?'),
        content: const Text('This confirms the dispatch has left for delivery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<DispatchDetailBloc>().add(MarkInTransitRequested(id));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmMarkDelivered(BuildContext context, String id) async {
    // Prefer an uploaded image if present, otherwise fall back to the
    // drawn signature on the pad.
    String? customerSig;
    String? driverSig;

    if (_customerSigFile != null) {
      customerSig = await _fileToBase64(_customerSigFile);
    } else if (!_customerSigCtrl.isEmpty) {
      customerSig = await _customerSigCtrl.exportBase64();
    }

    if (_driverSigFile != null) {
      driverSig = await _fileToBase64(_driverSigFile);
    } else if (!_driverSigCtrl.isEmpty) {
      driverSig = await _driverSigCtrl.exportBase64();
    }

    if (customerSig == null || driverSig == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload both signatures before proceeding.')),
      );
      return;
    }

    if (!context.mounted) return;
    context.read<DispatchDetailBloc>().add(MarkDeliveredRequested(
      id: id,
      customerSignatureBase64: customerSig,
      driverSignatureBase64: driverSig,
    ));
  }

  String _currency(double value) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.dispatch});
  final DispatchDetail dispatch;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    late Color color;
    late IconData icon;
    late String text;

    if (dispatch.isDelivered) {
      color = AppColors.info;
      icon = Icons.check_circle_rounded;
      text = 'Delivered on ${dispatch.deliveredAt != null ? dateFmt.format(dispatch.deliveredAt!) : '-'}';
    } else if (dispatch.isInTransit) {
      color = AppColors.warning;
      icon = Icons.local_shipping_rounded;
      text = 'In transit${dispatch.despatchedAt != null ? ' since ${dateFmt.format(dispatch.despatchedAt!)}' : ''}';
    } else {
      color = AppColors.warning;
      icon = Icons.local_shipping_outlined;
      text = 'Pending delivery';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5))),
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