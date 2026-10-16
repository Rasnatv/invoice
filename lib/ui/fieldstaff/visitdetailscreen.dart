import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_bloc.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_event.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_state.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/fieldstaffmodels/sitevisitdeletemodel.dart';
import '../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import '../../widgets/appsnackbar.dart';
import 'addsite.dart';

// =====================================================================
// SHARED LOOK (same as Create Estimate / Add Visit screens)
// =====================================================================

BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {this.color, this.size = 16});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon});
  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  _IconBadge(icon!),
                  SizedBox(width: Responsive.w(10)),
                ],
                Expanded(
                  child: Text(title,
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13))),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(14), Responsive.h(14), Responsive.w(14), Responsive.h(4)),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Label + value row used inside the section cards.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption(color: AppColors.textSecondary)
                        .copyWith(fontSize: Responsive.sp(10))),
                SizedBox(height: Responsive.h(2)),
                Text(value,
                    style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(12))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SCREEN
// =====================================================================

class FieldStaffVisitDetailScreen extends StatefulWidget {
  const FieldStaffVisitDetailScreen({super.key, required this.visitId});

  final String visitId;

  @override
  State<FieldStaffVisitDetailScreen> createState() => _FieldStaffVisitDetailScreenState();
}

class _FieldStaffVisitDetailScreenState extends State<FieldStaffVisitDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SiteVisitBloc>().add(
      ShowSiteVisitDetail(SiteVisitShowRequestModel(id: widget.visitId)),
    );
  }

  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      AppSnackbar.error('Could not start a call on this device');
    }
  }

  // Edit reuses AddFieldVisitScreen with `existing` set.
  void _openEdit(BuildContext context, SiteVisitDetailModel visit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SiteVisitBloc>(),
          child: AddFieldVisitScreen(existing: visit),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String customerName) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Visit',
      message: 'Remove the visit to "$customerName"? This cannot be undone.',
      confirmText: 'Delete',
    );
    if (confirmed && context.mounted) {
      context.read<SiteVisitBloc>().add(
        DeleteSiteVisit(SiteVisitDeleteRequestModel(id: widget.visitId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Visit Details', style: AppTextStyles.h6()),
          actions: [
            BlocBuilder<SiteVisitBloc, SiteVisitState>(
              buildWhen: (prev, curr) => prev.detail != curr.detail,
              builder: (context, state) {
                final visit = state.detail;
                final isPending =
                    visit != null && visit.statusLabel.trim().toLowerCase() == 'pending';
                if (!isPending) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: () => _openEdit(context, visit),
                );
              },
            ),
            BlocBuilder<SiteVisitBloc, SiteVisitState>(
              buildWhen: (prev, curr) =>
              prev.detail != curr.detail || prev.actionStatus != curr.actionStatus,
              builder: (context, state) {
                final visit = state.detail;
                final isPending =
                    visit != null && visit.statusLabel.trim().toLowerCase() == 'pending';
                if (!isPending) return const SizedBox.shrink();
                final busy = state.actionStatus == SiteVisitActionStatus.inProgress;
                return IconButton(
                  icon: busy
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                      : const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: busy ? null : () => _confirmDelete(context, visit.customerName),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<SiteVisitBloc, SiteVisitState>(
          listenWhen: (prev, curr) =>
          curr.actionStatus != prev.actionStatus &&
              (curr.actionStatus == SiteVisitActionStatus.success ||
                  curr.actionStatus == SiteVisitActionStatus.failure),
          listener: (context, state) {
            if (state.actionStatus == SiteVisitActionStatus.success) {
              Navigator.of(context).pop();
              AppSnackbar.success(state.actionMessage ?? 'Visit deleted');
              context.read<SiteVisitBloc>().add(const ResetSiteVisitActionStatus());
            } else if (state.actionStatus == SiteVisitActionStatus.failure) {
              AppSnackbar.error(state.actionMessage ?? 'Something went wrong');
              if (state.actionUnauthorized) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              context.read<SiteVisitBloc>().add(const ResetSiteVisitActionStatus());
            }
          },
          builder: (context, state) {
            if (state.isDetailLoading && state.detail == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.detailError != null && state.detail == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 32, color: AppColors.textSecondary.withOpacity(0.5)),
                      SizedBox(height: Responsive.h(10)),
                      Text(
                        state.detailError!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle().copyWith(fontSize: Responsive.sp(12)),
                      ),
                      SizedBox(height: Responsive.h(10)),
                      TextButton(
                        onPressed: () => context.read<SiteVisitBloc>().add(
                          ShowSiteVisitDetail(SiteVisitShowRequestModel(id: widget.visitId)),
                        ),
                        child: Text('Retry',
                            style: AppTextStyles.link().copyWith(fontSize: Responsive.sp(12))),
                      ),
                    ],
                  ),
                ),
              );
            }

            final visit = state.detail;
            if (visit == null) return const SizedBox.shrink();

            final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
            final parsedDate = DateTime.tryParse(visit.visitDate);
            final dateLabel = parsedDate != null
                ? DateFormat('dd MMM yyyy, EEEE').format(parsedDate)
                : visit.visitDate;
            final incentive = double.tryParse(visit.incentiveEarned) ?? 0;
            final budget = double.tryParse(visit.estimatedBudget) ?? 0;
            final sectionGap = SizedBox(height: Responsive.h(14));

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<SiteVisitBloc>().add(
                ShowSiteVisitDetail(SiteVisitShowRequestModel(id: widget.visitId)),
              ),
              child: SafeArea(
                child: ResponsiveCenter(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                    children: [
                      _headerCard(visit, dateLabel),
                      sectionGap,
                      _PhotoGallery(images: visit.images),
                      sectionGap,
                      _customerCard(context, visit),
                      sectionGap,
                      _incentiveCard(visit, currency, incentive),
                      if (visit.areaSqft.isNotEmpty ||
                          visit.estimatedBudget.isNotEmpty ||
                          visit.preferredProducts.isNotEmpty) ...[
                        sectionGap,
                        _projectCard(visit, currency, budget),
                      ],
                      if (visit.notes.isNotEmpty) ...[
                        sectionGap,
                        _notesCard(visit.notes),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- header (name + date + status) ----------------
  Widget _headerCard(SiteVisitDetailModel visit, String dateLabel) {
    final initial = visit.customerName.trim().isEmpty
        ? '?'
        : visit.customerName.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              initial,
              style: AppTextStyles.bodyBold(color: AppColors.primary)
                  .copyWith(fontSize: Responsive.sp(14)),
            ),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14)),
                ),
                SizedBox(height: Responsive.h(2)),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.textSecondary),
                    SizedBox(width: Responsive.w(4)),
                    Flexible(
                      child: Text(
                        dateLabel,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(color: AppColors.textSecondary)
                            .copyWith(fontSize: Responsive.sp(10.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (visit.statusLabel.isNotEmpty) ...[
            SizedBox(width: Responsive.w(8)),
            _Pill(label: visit.statusLabel, color: AppColors.warning),
          ],
        ],
      ),
    );
  }

  // ---------------- customer details ----------------
  Widget _customerCard(BuildContext context, SiteVisitDetailModel visit) {
    return _SectionCard(
      title: 'Customer Details',
      icon: Icons.groups_2_outlined,
      child: Column(
        children: [
          _DetailRow(
              icon: Icons.location_on_outlined, label: 'Address', value: visit.siteAddress),
          if (visit.customerEmail.isNotEmpty)
            _DetailRow(icon: Icons.alternate_email, label: 'Email', value: visit.customerEmail),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailRow(
                    icon: Icons.phone_outlined, label: 'Phone', value: visit.customerPhone),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(12)),
                child: Material(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _callNumber(context, visit.customerPhone),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(10), vertical: Responsive.h(7)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.call_rounded, size: 13, color: AppColors.primary),
                          SizedBox(width: Responsive.w(4)),
                          Text(
                            'Call',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: Responsive.sp(10.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- incentive ----------------
  Widget _incentiveCard(SiteVisitDetailModel visit, NumberFormat currency, double incentive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const _IconBadge(Icons.workspace_premium_rounded),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Text(
              visit.incentiveStatusLabel.isEmpty ? 'Incentive Earned' : visit.incentiveStatusLabel,
              style: AppTextStyles.caption(color: AppColors.textSecondary)
                  .copyWith(fontSize: Responsive.sp(11.5)),
            ),
          ),
          Text(
            currency.format(incentive),
            style: AppTextStyles.bodyBold(color: AppColors.primary)
                .copyWith(fontSize: Responsive.sp(14)),
          ),
        ],
      ),
    );
  }

  // ---------------- project details ----------------
  Widget _projectCard(SiteVisitDetailModel visit, NumberFormat currency, double budget) {
    return _SectionCard(
      title: 'Project Details',
      icon: Icons.construction_rounded,
      child: Column(
        children: [
          if (visit.areaSqft.isNotEmpty)
            _DetailRow(
                icon: Icons.square_foot_rounded,
                label: 'Area',
                value: '${visit.areaSqft} sq.ft'),
          if (visit.estimatedBudget.isNotEmpty)
            _DetailRow(
                icon: Icons.currency_rupee_rounded,
                label: 'Estimated Budget',
                value: currency.format(budget)),
          if (visit.preferredProducts.isNotEmpty)
            _DetailRow(
                icon: Icons.inventory_2_outlined,
                label: 'Preferred Products',
                value: visit.preferredProducts),
        ],
      ),
    );
  }

  // ---------------- notes ----------------
  Widget _notesCard(String notes) {
    return _SectionCard(
      title: 'Notes',
      icon: Icons.notes_rounded,
      child: Padding(
        padding: EdgeInsets.only(bottom: Responsive.h(10)),
        child: SizedBox(
          width: double.infinity,
          child: Text(notes, style: AppTextStyles.body().copyWith(fontSize: Responsive.sp(12))),
        ),
      ),
    );
  }
}

// =====================================================================
// PHOTO GALLERY (card with page counter)
// =====================================================================

class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.images});
  final List<SiteVisitImageModel> images;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final height = Responsive.h(200);

    if (images.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: _cardDecoration(),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _IconBadge(Icons.image_not_supported_outlined, size: 22),
            SizedBox(height: Responsive.h(8)),
            Text('No photo attached',
                style: AppTextStyles.caption(color: AppColors.textSecondary)
                    .copyWith(fontSize: Responsive.sp(11))),
          ],
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              return Image.network(
                images[i].imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined,
                      size: 28, color: AppColors.textSecondary.withOpacity(0.5)),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.background,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_page + 1} / ${images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(10.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}