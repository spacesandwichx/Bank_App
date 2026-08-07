import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../home/presentation/providers/home_providers.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountStreamProvider);
    final action = ref.watch(accountActionsProvider);
    final myAccount = accountAsync.valueOrNull;
    final balance = myAccount?.currentBalance ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BalanceHeader(balance: balance),
                const SizedBox(height: 24),
                _FieldLabel('Recipient account number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    hintText: '10-digit account number',
                    prefixIcon: Icon(Icons.account_circle_outlined,
                        size: 20, color: AppColors.textSecondary),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Enter an account number';
                    if (value.length != 10) {
                      return 'Account number must be 10 digits';
                    }
                    if (myAccount != null &&
                        value == myAccount.accountNumber) {
                      return 'You cannot transfer to your own account';
                    }
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
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Send Transfer'),
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

    final amount = double.parse(_amountController.text.trim());
    final accountNumber = _accountController.text.trim();
    final note = _noteController.text.trim();

    final recipientName =
        await ref.read(accountActionsProvider.notifier).transfer(
              recipientAccountNumber: accountNumber,
              amount: amount,
              note: note.isEmpty ? null : note,
            );

    if (!mounted) return;
    final state = ref.read(accountActionsProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Transfer failed: ${_readableError(state.error)}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Sent ${Formatters.money(amount)}'
            '${recipientName != null ? ' to $recipientName' : ''}',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    context.pop();
  }

  String _readableError(Object? error) {
    final text = error?.toString() ?? 'Unknown error';
    if (text.contains('Account number not found')) {
      return 'Recipient account not found';
    }
    if (text.contains('own account')) {
      return 'You cannot transfer to your own account';
    }
    if (text.contains('Insufficient balance')) {
      return 'Insufficient balance';
    }
    return text.replaceFirst('Exception: ', '');
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          AppTextStyles.bodyMuted.copyWith(fontWeight: FontWeight.w500),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available balance', style: AppTextStyles.bodyMuted),
              Text(
                Formatters.money(balance),
                style:
                    AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
