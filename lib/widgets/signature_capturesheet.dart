import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

/// Bottom sheet used on the dispatch detail screen to capture both the
/// customer's and the driver's signatures before marking a dispatch as
/// delivered.
///
/// Pops with a `{'customer': ..., 'driver': ...}` map of base64 PNG data
/// URIs (matching the shape POST /despatches/mark-delivered expects), or
/// `null` if the user cancels.
class SignatureCaptureSheet extends StatefulWidget {
  const SignatureCaptureSheet({super.key, required this.dsNumber});
  final String dsNumber;

  @override
  State<SignatureCaptureSheet> createState() => _SignatureCaptureSheetState();
}

class _SignatureCaptureSheetState extends State<SignatureCaptureSheet> {
  late final SignatureController _customerController;
  late final SignatureController _driverController;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _customerController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _driverController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _customerController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_customerController.isEmpty || _driverController.isEmpty) {
      setState(() => _error = 'Please collect both signatures before continuing.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final customerBytes = await _customerController.toPngBytes();
      final driverBytes = await _driverController.toPngBytes();

      if (customerBytes == null || driverBytes == null) {
        throw Exception('Could not capture signatures');
      }

      final customerDataUri = 'data:image/png;base64,${base64Encode(customerBytes)}';
      final driverDataUri = 'data:image/png;base64,${base64Encode(driverBytes)}';

      if (mounted) {
        Navigator.pop(context, {'customer': customerDataUri, 'driver': driverDataUri});
      }
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Failed to capture signatures: $e';
      });
    }
  }

  Widget _padBlock({required String title, required SignatureController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyBold()),
            TextButton(onPressed: controller.clear, child: const Text('Clear')),
          ],
        ),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Signature(controller: controller, backgroundColor: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Padding(
      padding: EdgeInsets.only(
        left: Responsive.w(18),
        right: Responsive.w(18),
        top: Responsive.h(18),
        bottom: MediaQuery.of(context).viewInsets.bottom + Responsive.h(18),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm Delivery — ${widget.dsNumber}', style: AppTextStyles.h6()),
            SizedBox(height: Responsive.h(4)),
            Text(
              'Collect signatures from the customer and driver to complete this delivery.',
              style: AppTextStyles.caption(),
            ),
            SizedBox(height: Responsive.h(16)),
            _padBlock(title: 'Customer Signature', controller: _customerController),
            SizedBox(height: Responsive.h(16)),
            _padBlock(title: 'Driver Signature', controller: _driverController),
            if (_error != null) ...[
              SizedBox(height: Responsive.h(10)),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
            SizedBox(height: Responsive.h(18)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Confirm Delivered'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
