import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.title = 'Yaqeen Bank', this.subtitle = 'PRIVATE BANKING'});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: const Icon(
            Icons.account_balance_outlined,
            color: AppColors.gold,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(title, style: AppTextStyles.displayMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
