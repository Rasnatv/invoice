// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import 'incentive_management_screen.dart' show SalesmanModel, SalesmanMonthlyBonus, BonusType;
//
// /// Opened from "Add Monthly Target" on the main Incentive screen.
// ///
// /// "Add Incentive" section: pick a salesman from a dropdown, see their
// /// current monthly target + incentive, and Edit or Delete it. Owner gives
// /// the target amount and incentive %/₹ on the setup page pushed from here.
// class SalesmanIncentiveListScreen extends StatefulWidget {
//   const SalesmanIncentiveListScreen({
//     super.key,
//     required this.salesmen,
//     required this.bonusBySalesman,
//     required this.currency,
//     required this.periodLabelFor,
//   });
//
//   final List<SalesmanModel> salesmen;
//
//   /// Same map instance the parent (IncentiveManagementScreen) owns —
//   /// mutated in place so edits/deletes here are reflected everywhere.
//   final Map<String, SalesmanMonthlyBonus> bonusBySalesman;
//   final NumberFormat currency;
//   final String Function(SalesmanMonthlyBonus) periodLabelFor;
//
//   @override
//   State<SalesmanIncentiveListScreen> createState() => _SalesmanIncentiveListScreenState();
// }
//
// class _SalesmanIncentiveListScreenState extends State<SalesmanIncentiveListScreen> {
//   late String _selectedSalesmanId = widget.salesmen.first.id;
//
//   SalesmanModel get _selectedSalesman =>
//       widget.salesmen.firstWhere((s) => s.id == _selectedSalesmanId, orElse: () => widget.salesmen.first);
//
//   SalesmanMonthlyBonus get _selectedBonus =>
//       widget.bonusBySalesman[_selectedSalesmanId] ??
//           SalesmanMonthlyBonus(month: DateTime.now().month, year: DateTime.now().year);
//
//   Future<void> _openSetup() async {
//     final salesman = _selectedSalesman;
//     final existing = _selectedBonus;
//     final result = await Navigator.of(context).push<SalesmanMonthlyBonus>(
//       MaterialPageRoute(
//         builder: (_) => SalesmanIncentiveSetupScreen(salesman: salesman, existing: existing),
//       ),
//     );
//     if (result != null) {
//       setState(() {
//         widget.bonusBySalesman[salesman.id] = result;
//       });
//     }
//   }
//
//   Future<void> _confirmDelete() async {
//     final salesman = _selectedSalesman;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text('Delete Incentive Setup?', style: AppTextStyles.bodyBold()),
//         content: Text(
//           'This will remove the monthly target and incentive set up for ${salesman.name}. This cannot be undone.',
//           style: AppTextStyles.caption(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       setState(() {
//         widget.bonusBySalesman[salesman.id] = SalesmanMonthlyBonus(
//           enabled: false,
//           month: DateTime.now().month,
//           year: DateTime.now().year,
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final bonus = _selectedBonus;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Add Monthly Target', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.all(Responsive.w(16)),
//           children: [
//             Text('Add Incentive', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16))),
//             SizedBox(height: Responsive.h(12)),
//
//             Text('Salesman', style: AppTextStyles.caption()),
//             SizedBox(height: Responsive.h(6)),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedSalesmanId,
//                   isExpanded: true,
//                   icon: const Icon(Icons.keyboard_arrow_down_rounded),
//                   items: [
//                     for (final s in widget.salesmen)
//                       DropdownMenuItem(
//                         value: s.id,
//                         child: Text(s.name, style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13.5))),
//                       ),
//                   ],
//                   onChanged: (v) {
//                     if (v != null) setState(() => _selectedSalesmanId = v);
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: Responsive.h(14)),
//
//             _SalesmanBonusCard(
//               key: ValueKey(_selectedSalesmanId),
//               salesmanName: _selectedSalesman.name,
//               bonus: bonus,
//               periodLabel: widget.periodLabelFor(bonus),
//               currency: widget.currency,
//               onEdit: _openSetup,
//               onDelete: bonus.enabled ? _confirmDelete : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Shows the selected salesman's monthly target + incentive, with Edit
// /// and Delete actions. Falls back to a simple "Add" prompt when nothing
// /// is set up yet for that salesman.
// class _SalesmanBonusCard extends StatelessWidget {
//   const _SalesmanBonusCard({
//     super.key,
//     required this.salesmanName,
//     required this.bonus,
//     required this.periodLabel,
//     required this.currency,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   final String salesmanName;
//   final SalesmanMonthlyBonus bonus;
//   final String periodLabel;
//   final NumberFormat currency;
//   final VoidCallback onEdit;
//   final VoidCallback? onDelete;
//
//   String get _bonusLabel =>
//       bonus.bonusType == BonusType.fixed ? currency.format(bonus.bonusValue) : '${bonus.bonusValue}%';
//
//   @override
//   Widget build(BuildContext context) {
//     if (!bonus.enabled) {
//       return Container(
//         padding: EdgeInsets.all(Responsive.w(16)),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.textSecondary.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.textSecondary),
//             ),
//             SizedBox(width: Responsive.w(12)),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('No incentive set up for $salesmanName', style: AppTextStyles.bodyBold()),
//                   SizedBox(height: Responsive.h(2)),
//                   Text(
//                     'Give a monthly target and an incentive % or fixed amount.',
//                     style: AppTextStyles.caption(),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: Responsive.w(8)),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
//               ),
//               onPressed: onEdit,
//               child: const Text('Add', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     const Icon(Icons.emoji_events_outlined, size: 18, color: Colors.black),
//                     SizedBox(width: Responsive.w(6)),
//                     Expanded(
//                       child: Text(
//                         '$salesmanName · Monthly Incentive',
//                         style: AppTextStyles.bodyBold(),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               InkWell(
//                 onTap: onEdit,
//                 borderRadius: BorderRadius.circular(8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(4),
//                   child: Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
//                 ),
//               ),
//               if (onDelete != null)
//                 InkWell(
//                   onTap: onDelete,
//                   borderRadius: BorderRadius.circular(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(4),
//                     child: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(4)),
//
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(4)),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.primary),
//                 SizedBox(width: Responsive.w(4)),
//                 Text(
//                   periodLabel,
//                   style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: Responsive.h(8)),
//
//           Text(
//             bonus.hasTarget
//                 ? (bonus.bonusType == BonusType.fixed
//                 ? 'Pays a fixed $_bonusLabel added to salary — only if total sales this period cross the target.'
//                 : 'Pays $_bonusLabel of sales added to salary — only if total sales this period cross the target.')
//                 : (bonus.bonusType == BonusType.fixed
//                 ? 'No target set — a fixed $_bonusLabel is added to salary for this period.'
//                 : 'No target set — $_bonusLabel applies directly to total sales this period.'),
//             style: AppTextStyles.caption(),
//           ),
//           SizedBox(height: Responsive.h(12)),
//
//           if (bonus.hasTarget) ...[
//             Text('Target: ${currency.format(bonus.target)}', style: AppTextStyles.caption()),
//             SizedBox(height: Responsive.h(8)),
//           ],
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   bonus.bonusType == BonusType.fixed ? 'Fixed: $_bonusLabel' : 'Rate: $_bonusLabel',
//                   style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// The actual incentive setup for one salesman, as a full page: salesman
// /// name, month, monthly target amount, and incentive % or fixed amount.
// class SalesmanIncentiveSetupScreen extends StatefulWidget {
//   const SalesmanIncentiveSetupScreen({
//     super.key,
//     required this.salesman,
//     required this.existing,
//   });
//
//   final SalesmanModel salesman;
//   final SalesmanMonthlyBonus existing;
//
//   @override
//   State<SalesmanIncentiveSetupScreen> createState() => _SalesmanIncentiveSetupScreenState();
// }
//
// class _SalesmanIncentiveSetupScreenState extends State<SalesmanIncentiveSetupScreen> {
//   late bool _enabled = widget.existing.enabled;
//   late bool _useTarget = widget.existing.hasTarget;
//   late int _month = widget.existing.month;
//   late int _year = widget.existing.year;
//   late BonusType _bonusType = widget.existing.bonusType;
//   late final _targetCtrl = TextEditingController(
//     text: widget.existing.hasTarget ? widget.existing.target!.toStringAsFixed(0) : '',
//   );
//   late final _bonusCtrl = TextEditingController(
//     text: widget.existing.bonusValue == 0 ? '' : widget.existing.bonusValue.toString(),
//   );
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     _targetCtrl.dispose();
//     _bonusCtrl.dispose();
//     super.dispose();
//   }
//
//   void _save() {
//     if (_enabled && !_formKey.currentState!.validate()) return;
//     Navigator.of(context).pop(
//       SalesmanMonthlyBonus(
//         enabled: _enabled,
//         month: _enabled ? _month : widget.existing.month,
//         year: _enabled ? _year : widget.existing.year,
//         target: _enabled && _useTarget ? double.parse(_targetCtrl.text.trim()) : null,
//         bonusType: _bonusType,
//         bonusValue: _enabled ? double.parse(_bonusCtrl.text.trim()) : 0,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currentYear = DateTime.now().year;
//     final years = [for (int y = currentYear - 1; y <= currentYear + 2; y++) y];
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: EdgeInsets.all(Responsive.w(16)),
//             children: [
//               // Salesman name, front and center.
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(12)),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundColor: AppColors.primary.withOpacity(0.18),
//                       child: Text(
//                         widget.salesman.name.isNotEmpty ? widget.salesman.name[0].toUpperCase() : '?',
//                         style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
//                       ),
//                     ),
//                     SizedBox(width: Responsive.w(10)),
//                     Expanded(
//                       child: Text(
//                         widget.salesman.name,
//                         style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: Responsive.h(16)),
//
//               SwitchListTile.adaptive(
//                 contentPadding: EdgeInsets.zero,
//                 value: _enabled,
//                 onChanged: (v) => setState(() => _enabled = v),
//                 title: Text('Bonus for a month?', style: AppTextStyles.bodyBold()),
//                 subtitle: Text(
//                   _enabled ? 'Yes — choose the month below.' : 'No bonus set up. Nothing else to fill in.',
//                   style: AppTextStyles.caption(),
//                 ),
//               ),
//
//               if (_enabled) ...[
//                 const Divider(height: 24, color: AppColors.border),
//
//                 Text('Applies to', style: AppTextStyles.caption()),
//                 SizedBox(height: Responsive.h(6)),
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: DropdownButtonFormField<int>(
//                         value: _month,
//                         isExpanded: true,
//                         decoration: const InputDecoration(hintText: 'Month'),
//                         items: [
//                           for (int m = 1; m <= 12; m++)
//                             DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(0, m)))),
//                         ],
//                         onChanged: (v) {
//                           if (v != null) setState(() => _month = v);
//                         },
//                       ),
//                     ),
//                     SizedBox(width: Responsive.w(10)),
//                     Expanded(
//                       flex: 2,
//                       child: DropdownButtonFormField<int>(
//                         value: _year,
//                         isExpanded: true,
//                         decoration: const InputDecoration(hintText: 'Year'),
//                         items: [for (final y in years) DropdownMenuItem(value: y, child: Text('$y'))],
//                         onChanged: (v) {
//                           if (v != null) setState(() => _year = v);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: Responsive.h(16)),
//
//                 SwitchListTile.adaptive(
//                   contentPadding: EdgeInsets.zero,
//                   value: _useTarget,
//                   onChanged: (v) => setState(() => _useTarget = v),
//                   title: Text('Set a sales target', style: AppTextStyles.bodyBold()),
//                   subtitle: Text(
//                     _useTarget
//                         ? 'Bonus is paid only after ${widget.salesman.name} crosses this target.'
//                         : 'Off: bonus applies to total monthly sales, no target needed.',
//                     style: AppTextStyles.caption(),
//                   ),
//                 ),
//                 if (_useTarget) ...[
//                   SizedBox(height: Responsive.h(10)),
//                   Text('Monthly Target Amount (₹)', style: AppTextStyles.caption()),
//                   SizedBox(height: Responsive.h(6)),
//                   TextFormField(
//                     controller: _targetCtrl,
//                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(hintText: 'e.g. 300000'),
//                     validator: (v) {
//                       if (!_enabled || !_useTarget) return null;
//                       if (v == null || v.trim().isEmpty) return 'Required';
//                       if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: Responsive.h(16)),
//                 ],
//
//                 Text('Incentive Type', style: AppTextStyles.caption()),
//                 SizedBox(height: Responsive.h(6)),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ChoiceChip(
//                         label: const Text('Fixed Amount'),
//                         selected: _bonusType == BonusType.fixed,
//                         selectedColor: AppColors.primary.withOpacity(0.18),
//                         onSelected: (_) => setState(() => _bonusType = BonusType.fixed),
//                       ),
//                     ),
//                     SizedBox(width: Responsive.w(10)),
//                     Expanded(
//                       child: ChoiceChip(
//                         label: const Text('Percentage'),
//                         selected: _bonusType == BonusType.percent,
//                         selectedColor: AppColors.primary.withOpacity(0.18),
//                         onSelected: (_) => setState(() => _bonusType = BonusType.percent),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: Responsive.h(16)),
//
//                 Text(
//                   _bonusType == BonusType.fixed
//                       ? (_useTarget
//                       ? 'Incentive Amount (₹) if Target Reached'
//                       : 'Incentive Amount (₹) on Total Sales')
//                       : (_useTarget ? 'Incentive % if Target Reached' : 'Incentive % on Total Sales'),
//                   style: AppTextStyles.caption(),
//                 ),
//                 SizedBox(height: Responsive.h(6)),
//                 TextFormField(
//                   controller: _bonusCtrl,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   decoration: InputDecoration(
//                     hintText: _bonusType == BonusType.fixed ? 'e.g. 5000' : 'e.g. 2',
//                     prefixText: _bonusType == BonusType.fixed ? '₹ ' : null,
//                     suffixText: _bonusType == BonusType.percent ? '%' : null,
//                   ),
//                   validator: (v) {
//                     if (!_enabled) return null;
//                     if (v == null || v.trim().isEmpty) return 'Required';
//                     if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
//                     return null;
//                   },
//                 ),
//               ],
//               SizedBox(height: Responsive.h(28)),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(10), Responsive.w(16), Responsive.h(14)),
//           child: SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
//               ),
//               onPressed: _save,
//               child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'incentive_management_screen.dart' show SalesmanModel, SalesmanMonthlyBonus, BonusType;

/// SCREEN 1 — "Add Incentive"
///
/// Deliberately simple: just pick a salesman from a dropdown. No incentive
/// fields live here — this screen's only job is selection. Setting the
/// actual target / incentive % / incentive amount happens on the separate
/// SalesmanIncentiveSetupScreen, opened via the button below.
class AddIncentiveScreen extends StatefulWidget {
  const AddIncentiveScreen({
    super.key,
    required this.salesmen,
    required this.bonusBySalesman,
    required this.currency,
    required this.periodLabelFor,
  });

  final List<SalesmanModel> salesmen;

  /// Same map instance the parent (IncentiveManagementScreen) owns —
  /// mutated in place so edits/deletes here are reflected everywhere.
  final Map<String, SalesmanMonthlyBonus> bonusBySalesman;
  final NumberFormat currency;
  final String Function(SalesmanMonthlyBonus) periodLabelFor;

  @override
  State<AddIncentiveScreen> createState() => _AddIncentiveScreenState();
}

class _AddIncentiveScreenState extends State<AddIncentiveScreen> {
  late String _selectedSalesmanId = widget.salesmen.first.id;

  SalesmanModel get _selectedSalesman =>
      widget.salesmen.firstWhere((s) => s.id == _selectedSalesmanId, orElse: () => widget.salesmen.first);

  SalesmanMonthlyBonus get _selectedBonus =>
      widget.bonusBySalesman[_selectedSalesmanId] ??
          SalesmanMonthlyBonus(month: DateTime.now().month, year: DateTime.now().year);

  String get _bonusLabel {
    final b = _selectedBonus;
    return b.bonusType == BonusType.fixed ? widget.currency.format(b.bonusValue) : '${b.bonusValue}%';
  }

  /// Opens the separate setup page for whichever salesman is selected.
  Future<void> _openSetup() async {
    final salesman = _selectedSalesman;
    final existing = _selectedBonus;
    final result = await Navigator.of(context).push<SalesmanMonthlyBonus>(
      MaterialPageRoute(
        builder: (_) => SalesmanIncentiveSetupScreen(salesman: salesman, existing: existing),
      ),
    );
    if (result != null) {
      setState(() {
        widget.bonusBySalesman[salesman.id] = result;
      });
    }
  }

  Future<void> _confirmRemove() async {
    final salesman = _selectedSalesman;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove Incentive?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will remove the monthly target and incentive set up for ${salesman.name}. This cannot be undone.',
          style: AppTextStyles.caption(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        widget.bonusBySalesman[salesman.id] = SalesmanMonthlyBonus(
          enabled: false,
          month: DateTime.now().month,
          year: DateTime.now().year,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final bonus = _selectedBonus;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Add Incentive', style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.w(16)),
          children: [
            Text(
              'Select a salesman to add or update their monthly target and incentive.',
              style: AppTextStyles.caption(),
            ),
            SizedBox(height: Responsive.h(16)),

            Text('Salesman', style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(6)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSalesmanId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: [
                    for (final s in widget.salesmen)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name, style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13.5))),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedSalesmanId = v);
                  },
                ),
              ),
            ),
            SizedBox(height: Responsive.h(14)),

            // Just a one-line status — no editable incentive fields here.
            Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
              decoration: BoxDecoration(
                color: bonus.enabled ? AppColors.primary.withOpacity(0.08) : AppColors.textSecondary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    bonus.enabled ? Icons.check_circle_outline : Icons.info_outline,
                    size: 16,
                    color: bonus.enabled ? AppColors.primary : AppColors.textSecondary,
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text(
                      bonus.enabled
                          ? (bonus.hasTarget
                          ? 'Current: Target ${widget.currency.format(bonus.target)} · $_bonusLabel · ${widget.periodLabelFor(bonus)}'
                          : 'Current: $_bonusLabel on total sales · ${widget.periodLabelFor(bonus)}')
                          : 'No incentive added yet for ${_selectedSalesman.name}.',
                      style: AppTextStyles.caption(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(20)),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _openSetup,
                child: Text(
                  bonus.enabled ? 'Edit Incentive Setup' : 'Setup Incentive',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            if (bonus.enabled) ...[
              SizedBox(height: Responsive.h(10)),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _confirmRemove,
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  label: const Text('Remove Incentive', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// SCREEN 2 — "Salesman Monthly Incentive Setup"
///
/// A completely separate page from AddIncentiveScreen. Opened only after
/// a salesman is picked there. Shows the assigned salesman's name plus the
/// actual fields: month, monthly target amount, and incentive % / amount.
class SalesmanIncentiveSetupScreen extends StatefulWidget {
  const SalesmanIncentiveSetupScreen({
    super.key,
    required this.salesman,
    required this.existing,
  });

  final SalesmanModel salesman;
  final SalesmanMonthlyBonus existing;

  @override
  State<SalesmanIncentiveSetupScreen> createState() => _SalesmanIncentiveSetupScreenState();
}

class _SalesmanIncentiveSetupScreenState extends State<SalesmanIncentiveSetupScreen> {
  late bool _enabled = widget.existing.enabled;
  late bool _useTarget = widget.existing.hasTarget;
  late int _month = widget.existing.month;
  late int _year = widget.existing.year;
  late BonusType _bonusType = widget.existing.bonusType;
  late final _targetCtrl = TextEditingController(
    text: widget.existing.hasTarget ? widget.existing.target!.toStringAsFixed(0) : '',
  );
  late final _bonusCtrl = TextEditingController(
    text: widget.existing.bonusValue == 0 ? '' : widget.existing.bonusValue.toString(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _targetCtrl.dispose();
    _bonusCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_enabled && !_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      SalesmanMonthlyBonus(
        enabled: _enabled,
        month: _enabled ? _month : widget.existing.month,
        year: _enabled ? _year : widget.existing.year,
        target: _enabled && _useTarget ? double.parse(_targetCtrl.text.trim()) : null,
        bonusType: _bonusType,
        bonusValue: _enabled ? double.parse(_bonusCtrl.text.trim()) : 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currentYear = DateTime.now().year;
    final years = [for (int y = currentYear - 1; y <= currentYear + 2; y++) y];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Salesman Monthly Incentive Setup', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(Responsive.w(16)),
            children: [
              // The assigned salesman for this setup page — shown clearly
              // so it's always obvious whose incentive you're editing.
              Text('Assigned Salesman', style: AppTextStyles.caption()),
              SizedBox(height: Responsive.h(6)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(12)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.18),
                      child: Text(
                        widget.salesman.name.isNotEmpty ? widget.salesman.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: Responsive.w(10)),
                    Expanded(
                      child: Text(
                        widget.salesman.name,
                        style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(18)),

              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
                title: Text('Bonus for a month?', style: AppTextStyles.bodyBold()),
                subtitle: Text(
                  _enabled ? 'Yes — choose the month below.' : 'No bonus set up. Nothing else to fill in.',
                  style: AppTextStyles.caption(),
                ),
              ),

              if (_enabled) ...[
                const Divider(height: 24, color: AppColors.border),

                Text('Applies to', style: AppTextStyles.caption()),
                SizedBox(height: Responsive.h(6)),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        value: _month,
                        isExpanded: true,
                        decoration: const InputDecoration(hintText: 'Month'),
                        items: [
                          for (int m = 1; m <= 12; m++)
                            DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(0, m)))),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _month = v);
                        },
                      ),
                    ),
                    SizedBox(width: Responsive.w(10)),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: _year,
                        isExpanded: true,
                        decoration: const InputDecoration(hintText: 'Year'),
                        items: [for (final y in years) DropdownMenuItem(value: y, child: Text('$y'))],
                        onChanged: (v) {
                          if (v != null) setState(() => _year = v);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(16)),

                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _useTarget,
                  onChanged: (v) => setState(() => _useTarget = v),
                  title: Text('Set a sales target', style: AppTextStyles.bodyBold()),
                  subtitle: Text(
                    _useTarget
                        ? 'Bonus is paid only after ${widget.salesman.name} crosses this target.'
                        : 'Off: bonus applies to total monthly sales, no target needed.',
                    style: AppTextStyles.caption(),
                  ),
                ),
                if (_useTarget) ...[
                  SizedBox(height: Responsive.h(10)),
                  Text('Monthly Target Amount (₹)', style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(6)),
                  TextFormField(
                    controller: _targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'e.g. 300000'),
                    validator: (v) {
                      if (!_enabled || !_useTarget) return null;
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(16)),
                ],

                Text('Incentive Type', style: AppTextStyles.caption()),
                SizedBox(height: Responsive.h(6)),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Fixed Amount'),
                        selected: _bonusType == BonusType.fixed,
                        selectedColor: AppColors.primary.withOpacity(0.18),
                        onSelected: (_) => setState(() => _bonusType = BonusType.fixed),
                      ),
                    ),
                    SizedBox(width: Responsive.w(10)),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Percentage'),
                        selected: _bonusType == BonusType.percent,
                        selectedColor: AppColors.primary.withOpacity(0.18),
                        onSelected: (_) => setState(() => _bonusType = BonusType.percent),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(16)),

                Text(
                  _bonusType == BonusType.fixed
                      ? (_useTarget
                      ? 'Incentive Amount (₹) if Target Reached'
                      : 'Incentive Amount (₹) on Total Sales')
                      : (_useTarget ? 'Incentive % if Target Reached' : 'Incentive % on Total Sales'),
                  style: AppTextStyles.caption(),
                ),
                SizedBox(height: Responsive.h(6)),
                TextFormField(
                  controller: _bonusCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: _bonusType == BonusType.fixed ? 'e.g. 5000' : 'e.g. 2',
                    prefixText: _bonusType == BonusType.fixed ? '₹ ' : null,
                    suffixText: _bonusType == BonusType.percent ? '%' : null,
                  ),
                  validator: (v) {
                    if (!_enabled) return null;
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
              ],
              SizedBox(height: Responsive.h(28)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(10), Responsive.w(16), Responsive.h(14)),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
              ),
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}