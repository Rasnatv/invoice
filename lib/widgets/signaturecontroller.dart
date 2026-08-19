import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignaturePadController {
  GlobalKey? _key;
  VoidCallback? _clearFn;
  bool Function()? _hasInkFn;

  void attach(GlobalKey key, VoidCallback clearFn, bool Function() hasInkFn) {
    _key = key;
    _clearFn = clearFn;
    _hasInkFn = hasInkFn;
  }

  void clear() => _clearFn?.call();

  bool get isEmpty => !(_hasInkFn?.call() ?? false);

  /// Returns a `data:image/png;base64,...` string, or null if nothing
  /// was drawn or the capture failed.
  Future<String?> exportBase64() async {
    if (isEmpty || _key == null) return null;
    final boundary = _key!.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return 'data:image/png;base64,${base64Encode(byteData.buffer.asUint8List())}';
  }
}

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.controller, this.height = 150});

  final SignaturePadController controller;
  final double height;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.attach(
      _repaintKey,
          () => setState(_points.clear),
          () => _points.any((p) => p != null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: GestureDetector(
          onPanStart: (d) => setState(() => _points.add(d.localPosition)),
          onPanUpdate: (d) => setState(() => _points.add(d.localPosition)),
          onPanEnd: (_) => _points.add(null),
          child: CustomPaint(
            painter: _SignaturePainter(_points),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}