
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Controller for a [SignaturePad]. Holds the drawn strokes, and exposes
/// [clear], [isEmpty], and [exportBase64] so the parent screen can pull the
/// signature out as a base64 PNG data URI once the driver is done drawing.
///
/// Extends [ChangeNotifier] so [SignaturePad] can listen for stroke updates
/// and repaint. ChangeNotifier already provides `dispose()` — that's what
/// was missing before (the class this replaces didn't extend anything, so
/// calling `.dispose()` on it in the screen's State.dispose() didn't
/// resolve to anything). We override it here just to also clear stroke
/// data before calling super.dispose().
class SignaturePadController extends ChangeNotifier {
  /// Each inner list is one continuous stroke (pointer down -> pointer up).
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  /// Wraps the drawing surface so we can rasterize it to a PNG on export.
  final GlobalKey repaintBoundaryKey = GlobalKey();

  bool _disposed = false;

  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  bool get isEmpty => _strokes.isEmpty || _strokes.every((s) => s.isEmpty);

  void startStroke(Offset point) {
    if (_disposed) return;
    _currentStroke = [point];
    _strokes.add(_currentStroke);
    notifyListeners();
  }

  void appendPoint(Offset point) {
    if (_disposed) return;
    _currentStroke.add(point);
    notifyListeners();
  }

  void endStroke() {
    if (_disposed) return;
    _currentStroke = [];
  }

  void clear() {
    if (_disposed) return;
    _strokes.clear();
    _currentStroke = [];
    notifyListeners();
  }

  /// Renders the current strokes to a PNG and returns it as a
  /// `data:image/png;base64,...` URI, matching what the mark-delivered API
  /// call expects. Returns null if nothing has been drawn or the render
  /// fails for any reason (e.g. called before the pad has laid out).
  Future<String?> exportBase64() async {
    if (isEmpty) return null;
    try {
      final boundary =
      repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      return 'data:image/png;base64,${base64Encode(bytes)}';
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _strokes.clear();
    _currentStroke = [];
    _disposed = true;
    super.dispose();
  }
}

/// A simple draw-to-sign pad. Pass a [SignaturePadController]; the pad
/// reads/writes strokes through it and repaints on every change.
class SignaturePad extends StatelessWidget {
  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 160,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.4,
    this.borderColor,
  });

  final SignaturePadController controller;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor ?? Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: RepaintBoundary(
        key: controller.repaintBoundaryKey,
        child: GestureDetector(
          onPanStart: (details) => controller.startStroke(details.localPosition),
          onPanUpdate: (details) => controller.appendPoint(details.localPosition),
          onPanEnd: (_) => controller.endStroke(),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _SignaturePainter(
                  strokes: controller.strokes,
                  color: strokeColor,
                  strokeWidth: strokeWidth,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}