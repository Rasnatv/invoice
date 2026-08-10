
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/sitevist/sitevisit_bloc.dart';
import '../../bloc/sitevist/sitevisit_event.dart';
import '../../bloc/sitevist/sitevisit_state.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/fieldstaffmodels/sitevisitdeletemodel.dart';
import '../../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import '../../widgets/appsnackbar.dart';
import 'addsite.dart';

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

  // ---------------- EDIT (this IS your "update" screen — it reuses
  // AddFieldVisitScreen with `existing` set) ----------------

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

  // ---------------- DELETE ----------------
  // FIX: the original had a stray duplicate `if` block and a mismatched
  // closing brace, which called DeleteSiteVisit twice and wouldn't compile.
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
    // Must run before any Responsive.w/h/sp call below.
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Visit Details', style: TextStyle(fontSize: Responsive.sp(17))),
          actions: [
            BlocBuilder<SiteVisitBloc, SiteVisitState>(
              buildWhen: (prev, curr) => prev.detail != curr.detail,
              builder: (context, state) {
                return IconButton(
                  icon: Icon(Icons.edit_rounded, size: Responsive.w(22)),
                  onPressed: state.detail == null ? null : () => _openEdit(context, state.detail!),
                );
              },
            ),
            BlocBuilder<SiteVisitBloc, SiteVisitState>(
              buildWhen: (prev, curr) =>
              prev.detail != curr.detail || prev.actionStatus != curr.actionStatus,
              builder: (context, state) {
                final busy = state.actionStatus == SiteVisitActionStatus.inProgress;
                return IconButton(
                  icon: busy
                      ? SizedBox(
                    width: Responsive.w(18),
                    height: Responsive.w(18),
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                      : Icon(Icons.delete_outline_rounded, size: Responsive.w(22)),
                  onPressed: (state.detail == null || busy)
                      ? null
                      : () => _confirmDelete(context, state.detail!.customerName),
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
                          size: Responsive.w(34), color: AppColors.textSecondary.withOpacity(0.5)),
                      SizedBox(height: Responsive.h(10)),
                      Text(
                        state.detailError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12.5)),
                      ),
                      SizedBox(height: Responsive.h(14)),
                      TextButton(
                        onPressed: () => context.read<SiteVisitBloc>().add(
                          ShowSiteVisitDetail(SiteVisitShowRequestModel(id: widget.visitId)),
                        ),
                        child: Text('Retry', style: TextStyle(fontSize: Responsive.sp(13))),
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

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<SiteVisitBloc>().add(
                ShowSiteVisitDetail(SiteVisitShowRequestModel(id: widget.visitId)),
              ),
              child: SafeArea(
                child: ResponsiveCenter(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(Responsive.w(20)),
                    children: [
                      _photoGallery(visit.images),
                      SizedBox(height: Responsive.h(18)),
                      _infoCard(context, visit: visit, dateLabel: dateLabel, currency: currency, incentive: incentive),
                      if (visit.notes.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(14)),
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

  Widget _photoGallery(List<SiteVisitImageModel> images) {
    final galleryHeight = Responsive.h(220);

    if (images.isEmpty) {
      return Container(
        height: galleryHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(Responsive.w(20)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: Responsive.w(34), color: AppColors.textSecondary.withOpacity(0.5)),
            SizedBox(height: Responsive.h(8)),
            Text('No photo attached', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12))),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: galleryHeight,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.w(20)),
                child: Image.network(
                  images[i].imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceAlt,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined,
                        size: Responsive.w(30), color: AppColors.textSecondary.withOpacity(0.5)),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surfaceAlt,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: Responsive.h(8)),
          Text(
            '${images.length} photos • swipe to view',
            style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(11)),
          ),
        ],
      ],
    );
  }

  Widget _infoCard(
      BuildContext context, {
        required SiteVisitDetailModel visit,
        required String dateLabel,
        required NumberFormat currency,
        required double incentive,
      }) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(18)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(visit.customerName, style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(17))),
              ),
              if (visit.statusLabel.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(9), vertical: Responsive.h(4)),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(Responsive.w(20)),
                  ),
                  child: Text(
                    visit.statusLabel,
                    style: TextStyle(color: AppColors.warning, fontSize: Responsive.sp(11), fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          SizedBox(height: Responsive.h(4)),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: Responsive.w(13), color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text(dateLabel, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12))),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.08)),
          SizedBox(height: Responsive.h(14)),
          _detailRow(icon: Icons.location_on_outlined, label: 'Address', value: visit.siteAddress),
          SizedBox(height: Responsive.h(12)),
          if (visit.customerEmail.isNotEmpty) ...[
            _detailRow(icon: Icons.email_outlined, label: 'Email', value: visit.customerEmail),
            SizedBox(height: Responsive.h(12)),
          ],
          Row(
            children: [
              Expanded(
                child: _detailRow(icon: Icons.phone_outlined, label: 'Phone', value: visit.customerPhone),
              ),
              Material(
                color: AppColors.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(Responsive.w(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Responsive.w(12)),
                  onTap: () => _callNumber(context, visit.customerPhone),
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(10)),
                    child: Icon(Icons.call_rounded, color: AppColors.info, size: Responsive.w(19)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(16)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Responsive.w(14)),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: Responsive.w(20)),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    visit.incentiveStatusLabel.isEmpty ? 'Incentive Earned' : visit.incentiveStatusLabel,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  currency.format(incentive),
                  style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(18)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: Responsive.w(16), color: AppColors.primary),
              SizedBox(width: Responsive.w(6)),
              Text('Notes', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13))),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          Text(notes, style: TextStyle(fontSize: Responsive.sp(12.5), color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _detailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: Responsive.w(16), color: AppColors.textSecondary),
        SizedBox(width: Responsive.w(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(10.5))),
              SizedBox(height: Responsive.h(2)),
              Text(value, style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}