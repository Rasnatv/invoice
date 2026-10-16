import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';

/// List-only shimmer (just the visit tiles). Spacing matches the real list
/// (10px gap, 90px bottom padding).
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
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (_, __) => const _ShimmerVisitTile(),
      ),
    );
  }
}

/// Full-page shimmer skeleton for [FieldStaffDashboardScreen].
/// Mirrors the real layout 1:1:
/// header (40px avatar, greeting/name, date, more icon) + floating 3-stat
/// card, 14px gap, search field, 12px gap, tab bar, 12px gap, visit tiles
/// (10px apart), 90px bottom padding.
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.h(14)),
                  // Search field
                  const _ShimmerSearch(),
                  SizedBox(height: Responsive.h(12)),
                  // Tab bar
                  const _ShimmerTabBar(),
                  SizedBox(height: Responsive.h(12)),
                  // Visit tiles
                  for (int i = 0; i < tileCount; i++) ...[
                    const _ShimmerVisitTile(),
                    if (i != tileCount - 1) SizedBox(height: Responsive.h(10)),
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

// ---------------- HEADER ----------------

class _ShimmerHeader extends StatelessWidget {
  const _ShimmerHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Responsive.h(46)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              Responsive.w(20),
              Responsive.h(14),
              Responsive.w(20),
              Responsive.h(48),
            ),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.10),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // avatar 40x40, radius 12
                  const _ShimmerBox(width: 40, height: 40, borderRadius: 12),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ShimmerBox(width: 80, height: 10, borderRadius: 4),
                        SizedBox(height: Responsive.h(4)),
                        const _ShimmerBox(width: 130, height: 15, borderRadius: 4),
                      ],
                    ),
                  ),
                  // calendar icon + date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _ShimmerBox(width: 12, height: 12, borderRadius: 4),
                      SizedBox(height: Responsive.h(3)),
                      const _ShimmerBox(width: 78, height: 9, borderRadius: 4),
                    ],
                  ),
                  SizedBox(width: Responsive.w(4)),
                  // more_vert icon (18px + 6px padding)
                  const Padding(
                    padding: EdgeInsets.all(6),
                    child: _ShimmerBox(width: 18, height: 18, borderRadius: 9),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: Responsive.h(11), horizontal: Responsive.w(6)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(child: _ShimmerStatColumn()),
                _statDivider(),
                const Expanded(child: _ShimmerStatColumn()),
                _statDivider(),
                const Expanded(child: _ShimmerStatColumn()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 28,
    color: AppColors.textSecondary.withOpacity(0.14),
  );
}

class _ShimmerStatColumn extends StatelessWidget {
  const _ShimmerStatColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ShimmerBox(width: 16, height: 16, borderRadius: 5),
        SizedBox(height: Responsive.h(4)),
        const _ShimmerBox(width: 40, height: 14, borderRadius: 4),
        SizedBox(height: Responsive.h(2)),
        const _ShimmerBox(width: 52, height: 9, borderRadius: 4),
      ],
    );
  }
}

// ---------------- SEARCH + TABS ----------------

class _ShimmerSearch extends StatelessWidget {
  const _ShimmerSearch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const _ShimmerBox(width: 18, height: 18, borderRadius: 9),
          const SizedBox(width: 10),
          const _ShimmerBox(width: 160, height: 10, borderRadius: 4),
        ],
      ),
    );
  }
}

class _ShimmerTabBar extends StatelessWidget {
  const _ShimmerTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // selected tab (filled pill)
          Expanded(
            child: _ShimmerBox(
              width: double.infinity,
              height: Responsive.h(30),
              borderRadius: 11,
            ),
          ),
          // unselected tab (just a label)
          Expanded(
            child: SizedBox(
              height: Responsive.h(30),
              child: const Center(
                child: _ShimmerBox(width: 56, height: 10, borderRadius: 4),
              ),
            ),
          ),
        ],
      ),
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

/// Mirrors _VisitTile: thumbnail + name/date + incentive, divider,
/// address row, phone row with Call button.
class _ShimmerVisitTile extends StatelessWidget {
  const _ShimmerVisitTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // thumbnail 38x38, radius 10
              const _ShimmerBox(width: 38, height: 38, borderRadius: 10),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShimmerBox(width: 130, height: 12, borderRadius: 4),
                    SizedBox(height: Responsive.h(6)),
                    const _ShimmerBox(width: 90, height: 10, borderRadius: 4),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              // incentive amount
              const _ShimmerBox(width: 52, height: 13, borderRadius: 4),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          // address row
          Row(
            children: [
              const _ShimmerBox(width: 13, height: 13, borderRadius: 4),
              SizedBox(width: Responsive.w(4)),
              const Expanded(
                child: _ShimmerBox(
                    width: double.infinity, height: 10, borderRadius: 4),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(6)),
          // phone row + Call button
          Row(
            children: [
              const _ShimmerBox(width: 12, height: 12, borderRadius: 4),
              SizedBox(width: Responsive.w(4)),
              const _ShimmerBox(width: 90, height: 10, borderRadius: 4),
              const Spacer(),
              const _ShimmerBox(width: 58, height: 24, borderRadius: 9),
            ],
          ),
        ],
      ),
    );
  }
}