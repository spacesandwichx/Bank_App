import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/balance_hero.dart';
import '../widgets/quick_actions.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final transactions = ref.watch(recentTransactionsProvider);
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.displayName?.split(' ').first) ??
        (user?.email.split('@').first ?? 'Guest');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(name: firstName),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Prestige Wealth',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 24),
                    BalanceHero(account: account),
                    const SizedBox(height: 32),
                    QuickActions(
                      actions: [
                        QuickAction(
                          icon: Icons.swap_horiz,
                          label: 'Transfer',
                          onTap: () {},
                        ),
                        QuickAction(
                          icon: Icons.credit_card_outlined,
                          label: 'Buy Cards',
                          onTap: () {},
                        ),
                        QuickAction(
                          icon: Icons.receipt_long_outlined,
                          label: 'Statements',
                          onTap: () {},
                        ),
                        QuickAction(
                          icon: Icons.menu,
                          label: 'Menu',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Transactions',
                            style: AppTextStyles.title.copyWith(fontSize: 16)),
                        TextButton(
                          onPressed: () {},
                          child: const Text('VIEW ALL'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < transactions.length; i++) ...[
                            TransactionTile(transaction: transactions[i]),
                            if (i != transactions.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Center(
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: AppTextStyles.title.copyWith(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back', style: AppTextStyles.bodyMuted),
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(icon: Icons.home_outlined, label: 'Home', selected: true),
              _NavItem(icon: Icons.credit_card_outlined, label: 'Cards'),
              _NavItem(icon: Icons.history, label: 'History'),
              _NavItem(icon: Icons.menu, label: 'Menu'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
