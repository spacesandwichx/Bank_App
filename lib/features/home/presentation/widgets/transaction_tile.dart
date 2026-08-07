import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionEntity transaction;

  IconData get _icon {
    if (transaction.direction == TransactionDirection.incoming) {
      return Icons.arrow_downward;
    }
    switch (transaction.type) {
      case TransactionType.cardPurchase:
        return Icons.card_giftcard;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.other:
        return Icons.arrow_upward;
    }
  }

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
              _icon,
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
