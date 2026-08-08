import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

enum ReceiptKind {
  transfer,
  cardPurchase,
  cardApplication,
  cheque,
  deposit,
  other,
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    super.key,
    required this.kind,
    required this.title,
    required this.amount,
    required this.reference,
    required this.timestamp,
    required this.rows,
    this.statusLabel = 'Completed',
    this.statusColor,
  });

  final ReceiptKind kind;
  final String title;
  final double amount;
  final String reference;
  final DateTime timestamp;
  final List<ReceiptRow> rows;
  final String statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final color = statusColor ?? AppColors.success;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_iconFor(kind),
                              color: color, size: 30),
                        ),
                        const SizedBox(height: 14),
                        Text(title,
                            style: AppTextStyles.title,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: color,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          Formatters.money(amount),
                          style:
                              AppTextStyles.balance.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        for (final r in rows) ...[
                          _RowLine(row: r),
                          const SizedBox(height: 10),
                        ],
                        _RowLine(
                          row: ReceiptRow(
                              label: 'Reference',
                              value: reference,
                              copyable: true),
                        ),
                        const SizedBox(height: 10),
                        _RowLine(
                          row: ReceiptRow(
                            label: 'Date',
                            value: Formatters.date(timestamp),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        Text(
                          'Thank you for banking with Al Yaqeen Bank',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ReceiptKind kind) {
    switch (kind) {
      case ReceiptKind.transfer:
        return Icons.swap_horiz;
      case ReceiptKind.cardPurchase:
        return Icons.card_giftcard;
      case ReceiptKind.cardApplication:
        return Icons.credit_card;
      case ReceiptKind.cheque:
        return Icons.receipt_long_outlined;
      case ReceiptKind.deposit:
        return Icons.account_balance_wallet_outlined;
      case ReceiptKind.other:
        return Icons.receipt_outlined;
    }
  }
}

class ReceiptRow {
  const ReceiptRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.row});

  final ReceiptRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            row.label,
            style: AppTextStyles.bodyMuted,
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  row.value,
                  textAlign: TextAlign.right,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (row.copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: row.value));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('${row.label} copied'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.naval,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
                  child: const Icon(Icons.copy_outlined,
                      size: 16, color: AppColors.gold),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
