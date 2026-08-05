import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';

import '../../../../core/dummymodel/contractor_model.dart';
import '../cubit/contractors_cubit.dart';

class AddContractorScreen extends StatefulWidget {
  const AddContractorScreen({super.key});

  @override
  State<AddContractorScreen> createState() => _AddContractorScreenState();
}

class _AddContractorScreenState extends State<AddContractorScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter contractor name'), backgroundColor: AppColors.error),
      );
      return;
    }
    context.read<ContractorsCubit>().addContractor(
          ContractorModel(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Contractor')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.w(20)),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: Responsive.w(44),
                    backgroundColor: AppColors.surfaceAlt,
                    child: Icon(Icons.apartment_rounded, size: Responsive.w(40), color: AppColors.textHint),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(28)),
            LabeledField(
              label: 'Contractor Name',
              field: CustomTextField(hint: 'Enter Name', icon: Icons.person_outline_rounded, controller: _nameCtrl),
            ),
            LabeledField(
              label: 'Phone Number',
              field: CustomTextField(
                hint: 'Enter Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                controller: _phoneCtrl,
              ),
            ),
            LabeledField(
              label: 'Site Address',
              field: CustomTextField(hint: 'Enter Address', icon: Icons.location_on_outlined, controller: _addressCtrl, maxLines: 2),
            ),
            SizedBox(height: Responsive.h(10)),
            PrimaryButton(label: 'Save Contractor', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
