import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../receipts/presentation/screens/receipt_screen.dart';
import '../../domain/entities/gift_card.dart';

class PurchaseSheet extends ConsumerStatefulWidget {
  const PurchaseSheet({super.key, required this.card});

  final GiftCard card;

  @override
  ConsumerState<PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends ConsumerState<PurchaseSheet> {
  late double _selected = widget.card.denominations.first;

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountStreamProvider);
    final actionState = ref.watch(accountActionsProvider);
    final balance =
        accountAsync.maybeWhen(data: (a) => a.currentBalance, orElse: () => 0.0);
    final insufficient = _selected > balance;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.card.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.card.icon,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.card.brand,
                            style: AppTextStyles.title.copyWith(fontSize: 16)),
                        Text(widget.card.tagline,
                            style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Choose denomination',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.card.denominations.map((d) {
                  final selected = d == _selected;
                  return ChoiceChip(
                    label: Text(Formatters.money(d)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selected = d),
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: selected ? AppColors.gold : AppColors.divider,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _SummaryRow(
                label: 'Available balance',
                value: Formatters.money(balance),
              ),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Total to pay',
                value: Formatters.money(_selected),
                emphasize: true,
              ),
              if (insufficient) ...[
                const SizedBox(height: 12),
                Text(
                  'Not enough balance for this purchase.',
                  style: AppTextStyles.bodyMuted
                      .copyWith(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    (actionState.isLoading || insufficient) ? null : _confirm,
                child: actionState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text('Buy ${widget.card.brand}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final txId = await ref.read(accountActionsProvider.notifier).purchase(
          merchant: '${widget.card.brand} Gift Card',
          amount: _selected,
          type: TransactionType.cardPurchase,
          description: 'Denomination ${Formatters.money(_selected)}',
        );

    if (!mounted) return;
    final state = ref.read(accountActionsProvider);
    Navigator.of(context).pop();

    if (state.hasError || txId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${state.error}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          kind: ReceiptKind.cardPurchase,
          title: '${widget.card.brand} gift card',
          amount: _selected,
          reference: txId,
          timestamp: DateTime.now(),
          rows: [
            ReceiptRow(label: 'Product', value: widget.card.brand),
            ReceiptRow(
              label: 'Denomination',
              value: Formatters.money(_selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        Text(
          value,
          style: emphasize
              ? AppTextStyles.title.copyWith(fontSize: 16)
              : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
