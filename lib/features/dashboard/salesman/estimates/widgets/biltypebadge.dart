import 'package:flutter/material.dart';
import '../../../../../../core/model/estimate_model.dart';
import '../../../../../../models/estimate_model.dart';



/// Green "Billed" / Red-orange "Quotation" pill, matching the paper form's
/// green "Billed" cell and red "Quotation" cell.
class BillTypeBadge extends StatelessWidget {
  final EstimateBillType billType;
  const BillTypeBadge({super.key, required this.billType});

  @override
  Widget build(BuildContext context) {
    final isBilled = billType == EstimateBillType.billed;
    final color = isBilled ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bg = isBilled ? const Color(0xFFE8F5E9) : const Color(0xFFFDECEA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        billType.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
