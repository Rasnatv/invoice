
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'cubit/dummymodel.dart';
import 'newcard.dart';
import 'owner_despatchdetailscreen.dart';


class OwnerdespatchScreen extends StatelessWidget {
  const OwnerdespatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final list = DispatchDummyData.bills;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Dispatch Bills', style: AppTextStyles.h6()),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(12)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search dispatch bills...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(child: Text('No dispatch bills yet', style: AppTextStyles.body()))
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final dispatch = list[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OwnerDispatchDetailScreen(dispatchId: dispatch.id),
                        ),
                      );
                    },
                    child: NewCard(dispatch: dispatch),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}