import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.direction == TransactionDirection.incoming;
    final amount = isIncoming ? transaction.amount : -transaction.amount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncoming
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: isIncoming ? AppColors.success : AppColors.naval,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchant,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.date(transaction.date),
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
          Text(
            Formatters.signedMoney(amount),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: isIncoming ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
