import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../receipts/presentation/screens/receipt_screen.dart';
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

    return InkWell(
      onTap: () => _openReceipt(context),
      child: Padding(
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
      ),
    );
  }

  void _openReceipt(BuildContext context) {
    final isIncoming =
        transaction.direction == TransactionDirection.incoming;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          kind: _receiptKind,
          title: transaction.merchant,
          amount: transaction.amount,
          reference: transaction.id,
          timestamp: transaction.date,
          statusColor: isIncoming ? AppColors.success : AppColors.naval,
          rows: [
            ReceiptRow(
              label: 'Direction',
              value: isIncoming ? 'Incoming' : 'Outgoing',
            ),
            ReceiptRow(label: 'Category', value: _categoryLabel),
            if (transaction.description != null &&
                transaction.description!.isNotEmpty)
              ReceiptRow(label: 'Note', value: transaction.description!),
          ],
        ),
      ),
    );
  }

  ReceiptKind get _receiptKind {
    switch (transaction.type) {
      case TransactionType.transfer:
        return ReceiptKind.transfer;
      case TransactionType.cardPurchase:
        return ReceiptKind.cardPurchase;
      case TransactionType.deposit:
        return ReceiptKind.deposit;
      case TransactionType.other:
        return ReceiptKind.other;
    }
  }

  String get _categoryLabel {
    switch (transaction.type) {
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.cardPurchase:
        return 'Card purchase';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.other:
        return 'Other';
    }
  }
}
