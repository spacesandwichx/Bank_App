import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/account_entity.dart';

class BalanceHero extends StatelessWidget {
  const BalanceHero({super.key, required this.account});

  final AccountEntity account;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.gold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TOTAL BALANCE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.money(account.totalBalance),
                  style: AppTextStyles.balance,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AccountBreakdown(
              label: 'Current Account',
              amount: account.currentBalance,
            ),
            Container(
              width: 1,
              height: 32,
              color: AppColors.divider,
            ),
            _AccountBreakdown(
              label: 'Savings Account',
              amount: account.savingsBalance,
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountBreakdown extends StatelessWidget {
  const _AccountBreakdown({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          Formatters.money(amount),
          style: AppTextStyles.title,
        ),
      ],
    );
  }
}
