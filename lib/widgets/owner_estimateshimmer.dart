// import 'package:flutter/material.dart';
//
// /// A reusable shimmer/skeleton-loading effect widget for Flutter.
// ///
// /// Wrap any placeholder layout (built from [ShimmerBox]es, or your own
// /// grey containers) with [ShimmerLoading] to get an animated "sweeping
// /// light" effect commonly used for loading states (Facebook/LinkedIn style).
// ///
// /// Usage:
// /// ```dart
// /// ShimmerLoading(
// ///   child: ListView.builder(
// ///     itemCount: 6,
// ///     itemBuilder: (_, __) => const MyCardSkeleton(),
// ///   ),
// /// )
// /// ```
// class ShimmerLoading extends StatefulWidget {
//   const ShimmerLoading({
//     super.key,
//     required this.child,
//     this.baseColor = const Color(0xFFE0E0E0),
//     this.highlightColor = const Color(0xFFF5F5F5),
//     this.duration = const Duration(milliseconds: 1400),
//     this.enabled = true,
//   });
//
//   /// The skeleton layout to animate. Typically built from [ShimmerBox]
//   /// widgets arranged to match the shape of the real content.
//   final Widget child;
//
//   /// The darker "resting" color of the shimmer gradient.
//   final Color baseColor;
//
//   /// The lighter color that sweeps across the shimmer gradient.
//   final Color highlightColor;
//
//   /// How long one sweep cycle takes.
//   final Duration duration;
//
//   /// Set to false to render [child] statically without animating
//   /// (useful if you want to conditionally disable the effect).
//   final bool enabled;
//
//   @override
//   State<ShimmerLoading> createState() => _ShimmerLoadingState();
// }
//
// class _ShimmerLoadingState extends State<ShimmerLoading>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: widget.duration);
//     if (widget.enabled) _controller.repeat();
//   }
//
//   @override
//   void didUpdateWidget(covariant ShimmerLoading oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.enabled != oldWidget.enabled) {
//       if (widget.enabled) {
//         _controller.repeat();
//       } else {
//         _controller.stop();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.enabled) return widget.child;
//
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         final double t = _controller.value;
//         return ShaderMask(
//           blendMode: BlendMode.srcATop,
//           shaderCallback: (bounds) {
//             return LinearGradient(
//               colors: [
//                 widget.baseColor,
//                 widget.highlightColor,
//                 widget.baseColor,
//               ],
//               stops: const [0.1, 0.5, 0.9],
//               begin: Alignment(-1.0 - t * 2, 0),
//               end: Alignment(1.0 - t * 2, 0),
//             ).createShader(bounds);
//           },
//           child: child,
//         );
//       },
//       child: widget.child,
//     );
//   }
// }
//
// /// A plain rounded grey block used as a placeholder piece inside a
// /// skeleton layout (e.g. standing in for a line of text, an avatar,
// /// or a button while real content loads).
// class ShimmerBox extends StatelessWidget {
//   const ShimmerBox({
//     super.key,
//     this.width,
//     required this.height,
//     this.borderRadius = 6,
//     this.color,
//   });
//
//   /// Width of the box. Pass null to let it expand to fill available space
//   /// (e.g. inside an [Expanded] or a [Row] with [CrossAxisAlignment.stretch]).
//   final double? width;
//
//   final double height;
//
//   final double borderRadius;
//
//   /// Override the placeholder color. Defaults to a neutral grey; the
//   /// [ShimmerLoading] ancestor will tint/animate it regardless via
//   /// [ShaderMask], so this mostly matters when [ShimmerLoading.enabled]
//   /// is false.
//   final Color? color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: color ?? Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(borderRadius),
//       ),
//     );
//   }
// }
//
// /// A circular variant of [ShimmerBox], useful for avatar/profile-photo
// /// placeholders.
// class ShimmerCircle extends StatelessWidget {
//   const ShimmerCircle({super.key, required this.diameter, this.color});
//
//   final double diameter;
//   final Color? color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: diameter,
//       height: diameter,
//       decoration: BoxDecoration(
//         color: color ?? Colors.grey.shade300,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }
//
// /// A ready-made list of shimmering placeholder cards, for the common case
// /// of "show N skeleton items while a list loads."
// ///
// /// Usage:
// /// ```dart
// /// ShimmerListPlaceholder(
// ///   itemCount: 6,
// ///   itemBuilder: (_, __) => const _OwnerEstimateCardSkeleton(),
// ///   separatorHeight: 10,
// ///   padding: EdgeInsets.all(16),
// /// )
// /// ```
// class ShimmerListPlaceholder extends StatelessWidget {
//   const ShimmerListPlaceholder({
//     super.key,
//     required this.itemCount,
//     required this.itemBuilder,
//     this.separatorHeight = 10,
//     this.padding = EdgeInsets.zero,
//   });
//
//   final int itemCount;
//   final Widget Function(BuildContext context, int index) itemBuilder;
//   final double separatorHeight;
//   final EdgeInsets padding;
//
//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoading(
//       child: ListView.separated(
//         padding: padding,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: itemCount,
//         separatorBuilder: (_, __) => SizedBox(height: separatorHeight),
//         itemBuilder: itemBuilder,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

/// A reusable shimmer/skeleton-loading effect widget for Flutter.
///
/// Wrap any placeholder layout (built from [ShimmerBox]es, or your own
/// grey containers) with [ShimmerLoading] to get an animated "sweeping
/// light" effect commonly used for loading states (Facebook/LinkedIn style).
///
/// Usage:
/// ```dart
/// ShimmerLoading(
///   child: ListView.builder(
///     itemCount: 6,
///     itemBuilder: (_, __) => const MyCardSkeleton(),
///   ),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1400),
    this.enabled = true,
  });

  /// The skeleton layout to animate. Typically built from [ShimmerBox]
  /// widgets arranged to match the shape of the real content.
  final Widget child;

  /// The darker "resting" color of the shimmer gradient.
  final Color baseColor;

  /// The lighter color that sweeps across the shimmer gradient.
  final Color highlightColor;

  /// How long one sweep cycle takes.
  final Duration duration;

  /// Set to false to render [child] statically without animating
  /// (useful if you want to conditionally disable the effect).
  final bool enabled;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.0 - t * 2, 0),
              end: Alignment(1.0 - t * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A plain rounded grey block used as a placeholder piece inside a
/// skeleton layout (e.g. standing in for a line of text, an avatar,
/// or a button while real content loads).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 6,
    this.color,
  });

  /// Width of the box. Pass null to let it expand to fill available space
  /// (e.g. inside an [Expanded] or a [Row] with [CrossAxisAlignment.stretch]).
  final double? width;

  final double height;

  final double borderRadius;

  /// Override the placeholder color. Defaults to a neutral grey; the
  /// [ShimmerLoading] ancestor will tint/animate it regardless via
  /// [ShaderMask], so this mostly matters when [ShimmerLoading.enabled]
  /// is false.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A circular variant of [ShimmerBox], useful for avatar/profile-photo
/// placeholders.
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, required this.diameter, this.color});

  final double diameter;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A ready-made list of shimmering placeholder cards, for the common case
/// of "show N skeleton items while a list loads."
///
/// Usage:
/// ```dart
/// ShimmerListPlaceholder(
///   itemCount: 6,
///   itemBuilder: (_, __) => const _OwnerEstimateCardSkeleton(),
///   separatorHeight: 10,
///   padding: EdgeInsets.all(16),
/// )
/// ```
class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorHeight = 10,
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double separatorHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: separatorHeight),
        itemBuilder: itemBuilder,
      ),
    );
  }
}