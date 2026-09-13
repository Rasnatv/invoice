import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Base shimmer effect wrapper — animates a moving gradient sheen
/// across whatever child you give it. No external package required.
class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE6E8EB),
    this.highlightColor = const Color(0xFFF6F7F8),
    this.duration = const Duration(milliseconds: 1300),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  /// Rounded-rectangle placeholder block (text lines, cards, images).
  factory ShimmerWidget.rectangular({
    Key? key,
    double width = double.infinity,
    required double height,
    double borderRadius = 8,
  }) {
    return ShimmerWidget(
      key: key,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Circular placeholder (avatars, round icon badges).
  factory ShimmerWidget.circular({Key? key, required double size}) {
    return ShimmerWidget(
      key: key,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
            stops: const [0.1, 0.5, 0.9],
            begin: const Alignment(-1.0, -0.3),
            end: const Alignment(1.0, 0.3),
            transform: _SlidingGradientTransform(slidePercent: _controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

// ---------------- SCREEN-SPECIFIC SKELETONS (Owner Dashboard) ----------------

/// Skeleton for the 4 mini-stat columns in the owner header
/// (Total / Dispatched / Quotations / Pending).
class HeaderStatsShimmer extends StatelessWidget {
  const HeaderStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget stat() => Column(
      children: [
        ShimmerWidget.circular(size: 26),
        SizedBox(height: Responsive.h(6)),
        ShimmerWidget.rectangular(width: 28, height: 14, borderRadius: 4),
        SizedBox(height: Responsive.h(4)),
        ShimmerWidget.rectangular(width: 42, height: 9, borderRadius: 4),
      ],
    );

    return Row(
      children: [
        Expanded(child: stat()),
        _divider(),
        Expanded(child: stat()),
        _divider(),
        Expanded(child: stat()),
        _divider(),
        Expanded(child: stat()),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: AppColors.textSecondary.withOpacity(0.08));
}

/// Skeleton for the horizontal "Quick Actions" row — mimics N icon+label tiles.
class QuickActionsShimmer extends StatelessWidget {
  const QuickActionsShimmer({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.h(100),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(12)),
        itemBuilder: (context, i) => SizedBox(
          width: Responsive.w(84),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(10), horizontal: Responsive.w(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerWidget.circular(size: 36),
                SizedBox(height: Responsive.h(8)),
                ShimmerWidget.rectangular(width: 52, height: 9, borderRadius: 4),
                SizedBox(height: Responsive.h(4)),
                ShimmerWidget.rectangular(width: 36, height: 9, borderRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton for the Sales Overview card content (bar-chart style).
class SalesOverviewShimmer extends StatelessWidget {
  const SalesOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final heights = [40.0, 70.0, 55.0, 90.0, 65.0, 48.0];
    return SizedBox(
      height: Responsive.h(140),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final h in heights)
            ShimmerWidget.rectangular(width: 22, height: Responsive.h(h), borderRadius: 6),
        ],
      ),
    );
  }
}

/// Skeleton mimicking a single _RecentEstimateCard.
class RecentEstimateShimmerCard extends StatelessWidget {
  const RecentEstimateShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              ShimmerWidget.rectangular(width: 120, height: 14, borderRadius: 4),
              ShimmerWidget.rectangular(width: 60, height: 18, borderRadius: 9),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          ShimmerWidget.rectangular(width: 90, height: 10, borderRadius: 4),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangular(width: 70, height: 10, borderRadius: 4),
              ShimmerWidget.rectangular(width: 60, height: 14, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Convenience list of N shimmer estimate cards with spacing already applied.
/// Use this in place of the loading branch for the "Recent Estimates" section.
class RecentEstimateListShimmer extends StatelessWidget {
  const RecentEstimateListShimmer({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          const RecentEstimateShimmerCard(),
          if (i != count - 1) SizedBox(height: Responsive.h(10)),
        ],
      ],
    );
  }
}