import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';

/// Shimmer loading state for [FieldStaffDashboardScreen].
///
/// Drop this in place of the visit list while data is being fetched:
///
/// ```dart
/// isInitialLoading ? const FieldStaffShimmerDashboard() : TabBarView(...)
/// ```
class FieldStaffShimmerDashboard extends StatelessWidget {
  const FieldStaffShimmerDashboard({super.key, this.itemCount = 6});

  /// How many placeholder tiles to render.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          Responsive.w(20),
          Responsive.h(4),
          Responsive.w(20),
          Responsive.h(90),
        ),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
        itemBuilder: (_, __) => const _ShimmerVisitTile(),
      ),
    );
  }
}

/// Full-page shimmer skeleton for [FieldStaffDashboardScreen] — mimics the
/// header, stats card, search bar, tab bar, and visit list all at once.
///
/// Use this instead of [FieldStaffShimmerDashboard] when you want the whole
/// screen to shimmer on first load, not just the list area:
///
/// ```dart
/// body: isInitialLoading ? const FieldStaffFullShimmer() : <real screen content>,
/// ```
class FieldStaffFullShimmer extends StatelessWidget {
  const FieldStaffFullShimmer({super.key, this.tileCount = 5});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerHeader(),
            SizedBox(height: Responsive.h(55)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _ShimmerBox(width: double.infinity, height: 46, borderRadius: 16),
                  SizedBox(height: Responsive.h(16)),
                  // Tab bar
                  _ShimmerBox(width: double.infinity, height: 44, borderRadius: 16),
                  SizedBox(height: Responsive.h(14)),
                  // Visit tiles
                  for (int i = 0; i < tileCount; i++) ...[
                    const _ShimmerVisitTile(),
                    if (i != tileCount - 1) SizedBox(height: Responsive.h(12)),
                  ],
                  SizedBox(height: Responsive.h(90)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerHeader extends StatelessWidget {
  const _ShimmerHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(20),
            Responsive.w(20),
            Responsive.h(52),
          ),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.10),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _ShimmerBox(width: 50, height: 50, borderRadius: 25),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBox(width: 90, height: 11),
                          SizedBox(height: Responsive.h(8)),
                          _ShimmerBox(width: 140, height: 16),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    const _ShimmerBox(width: 38, height: 38, borderRadius: 19),
                  ],
                ),
                SizedBox(height: Responsive.h(16)),
                _ShimmerBox(width: 150, height: 26, borderRadius: 20),
                SizedBox(height: Responsive.h(10)),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(50),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16), horizontal: Responsive.w(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Expanded(child: _ShimmerStatColumn()),
                _statDivider(),
                Expanded(child: _ShimmerStatColumn()),
                _statDivider(),
                Expanded(child: _ShimmerStatColumn()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 37,
    color: AppColors.textSecondary.withOpacity(0.10),
  );
}

class _ShimmerStatColumn extends StatelessWidget {
  const _ShimmerStatColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ShimmerBox(width: 30, height: 30, borderRadius: 15),
        SizedBox(height: Responsive.h(6)),
        const _ShimmerBox(width: 40, height: 13),
        SizedBox(height: Responsive.h(4)),
        const _ShimmerBox(width: 55, height: 9),
      ],
    );
  }
}

// ---------------- SHIMMER ANIMATION WRAPPER ----------------

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

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
        final dx = _controller.value * 2 - 1; // sweeps from -1 to 1
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + dx, 0),
              end: Alignment(1 + dx, 0),
              colors: [
                AppColors.textSecondary.withOpacity(0.14),
                Colors.white.withOpacity(0.95),
                AppColors.textSecondary.withOpacity(0.14),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ---------------- SHIMMER PRIMITIVES ----------------

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.16),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _ShimmerVisitTile extends StatelessWidget {
  const _ShimmerVisitTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(13)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(width: 46, height: 46, borderRadius: 12),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 130, height: 13),
                    SizedBox(height: Responsive.h(8)),
                    _ShimmerBox(width: 90, height: 10),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _ShimmerBox(width: 54, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.08)),
          SizedBox(height: Responsive.h(12)),
          _ShimmerBox(width: double.infinity, height: 11),
          SizedBox(height: Responsive.h(10)),
          Row(
            children: [
              _ShimmerBox(width: 100, height: 11),
              const Spacer(),
              _ShimmerBox(width: 64, height: 24, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}