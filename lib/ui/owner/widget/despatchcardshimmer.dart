import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';


/// Self-contained shimmer for the dispatch list. No external shimmer
/// package and no dependency on other shimmer widgets.
///
/// Usage:
///   DispatchListShimmer(itemCount: 6, padding: listPadding)
///
/// All cards share one animation, so the highlight sweeps in sync.
class DispatchListShimmer extends StatelessWidget {
  const DispatchListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.separatorHeight,
  });

  final int itemCount;
  final EdgeInsets? padding;
  final double? separatorHeight;

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            SizedBox(height: separatorHeight ?? Responsive.h(10)),
        itemBuilder: (_, __) => const DispatchCardShimmer(),
      ),
    );
  }
}

/// One placeholder card: icon tile, DS number + party lines, status pill,
/// divider, reference row with chevron.
class DispatchCardShimmer extends StatelessWidget {
  const DispatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final card = _card();
    // If used on its own (outside DispatchListShimmer), animate by itself.
    return _ShimmerScope.maybeOf(context) != null ? card : _ShimmerScope(child: card);
  }

  Widget _card() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon tile, DS number + party, status pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Bone(width: 42, height: 42, radius: 12),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: Responsive.w(130), height: 14),
                    SizedBox(height: Responsive.h(8)),
                    _Bone(width: Responsive.w(90), height: 11),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _Bone(width: Responsive.w(64), height: 20, radius: 10),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          // Ref row + chevron
          Row(
            children: [
              const _Bone(width: 14, height: 14, radius: 7),
              SizedBox(width: Responsive.w(6)),
              _Bone(width: Responsive.w(120), height: 11),
              const Spacer(),
              const _Bone(width: 18, height: 18, radius: 9),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Internals
// ---------------------------------------------------------------------

const Color _baseColor = Color(0xFFE5E7EB);
const Color _highlightColor = Color(0xFFF3F4F6);

/// A grey rounded rectangle with a moving highlight. It listens to the
/// nearest shimmer scope, so every bone animates from the same clock.
class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.radius = 6});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = _ShimmerScope.valueOf(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [_baseColor, _highlightColor, _baseColor],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideTransform(width * (t * 3 - 1.5)),
        ),
      ),
    );
  }
}

class _ShimmerScope extends StatefulWidget {
  const _ShimmerScope({required this.child});
  final Widget child;

  static bool? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ShimmerInherited>() == null
          ? null
          : true;

  /// Current animation value (0..1). Registers a rebuild dependency.
  static double valueOf(BuildContext context) {
    final inherited =
    context.dependOnInheritedWidgetOfExactType<_ShimmerInherited>();
    return inherited?.notifier?.value ?? 0;
  }

  @override
  State<_ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<_ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerInherited(notifier: _controller, child: widget.child);
  }
}

class _ShimmerInherited extends InheritedNotifier<AnimationController> {
  const _ShimmerInherited({required super.notifier, required super.child});
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.dx);
  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}