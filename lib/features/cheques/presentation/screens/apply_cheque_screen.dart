import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../receipts/presentation/screens/receipt_screen.dart';
import '../providers/cheque_providers.dart';

class ApplyChequeScreen extends ConsumerStatefulWidget {
  const ApplyChequeScreen({super.key});

  @override
  ConsumerState<ApplyChequeScreen> createState() => _ApplyChequeScreenState();
}

class _ApplyChequeScreenState extends ConsumerState<ApplyChequeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(chequeActionsProvider);
    final balance = ref
            .watch(accountStreamProvider)
            .valueOrNull
            ?.currentBalance ??
        0;

    return Scaffold(
      appBar: AppBar(title: const Text('Request a cheque')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available balance',
                              style: AppTextStyles.bodyMuted),
                          Text(
                            Formatters.money(balance),
                            style: AppTextStyles.title
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _FieldLabel('Payee name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _payeeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Who is this cheque for?',
                    prefixIcon: Icon(Icons.person_outline,
                        size: 20, color: AppColors.textSecondary),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.length < 2) return 'Enter the payee name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _FieldLabel('Amount'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money,
                        size: 20, color: AppColors.textSecondary),
                  ),
                  validator: (v) {
                    final parsed = double.tryParse(v?.trim() ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }
                    if (parsed > balance) {
                      return 'Amount exceeds your balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _FieldLabel('Note (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    hintText: 'What is this for?',
                    prefixIcon: Icon(Icons.notes,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: action.isLoading ? null : _submit,
                  child: action.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Issue cheque'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final payee = _payeeController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();

    final result = await ref.read(chequeActionsProvider.notifier).request(
          payeeName: payee,
          amount: amount,
          note: note.isEmpty ? null : note,
        );

    if (!mounted) return;
    final state = ref.read(chequeActionsProvider);
    if (state.hasError || result == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Cheque failed: ${state.error?.toString().replaceFirst('Exception: ', '') ?? 'Unknown error'}',
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.pop();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          kind: ReceiptKind.cheque,
          title: 'Cheque issued',
          amount: result.amount,
          reference: result.number,
          timestamp: DateTime.now(),
          statusLabel: 'Pending',
          statusColor: AppColors.gold,
          rows: [
            ReceiptRow(label: 'Payee', value: result.payeeName),
            if (result.note != null && result.note!.isNotEmpty)
              ReceiptRow(label: 'Note', value: result.note!),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMuted.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
