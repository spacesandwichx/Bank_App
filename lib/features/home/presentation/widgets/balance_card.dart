import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/account_entity.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, required this.account});

  final AccountEntity account;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = false;

  String _formattedBalance() {
    final double amount = widget.account.currentBalance;
    final formattedAmount = amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return formattedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AVAILABLE BALANCE',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _hidden = !_hidden),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_hidden)
            Text(
              '••••••••',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 4,
              ),
            )
          else
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _formattedBalance(),
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: 'LYD',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
