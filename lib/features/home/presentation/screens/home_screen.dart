import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountStreamProvider);
    final txAsync = ref.watch(recentTransactionsStreamProvider);
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.displayName?.split(' ').first) ??
        (user?.email.split('@').first ?? 'Guest');

    return Scaffold(
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () async {
            ref.invalidate(accountStreamProvider);
            ref.invalidate(recentTransactionsStreamProvider);
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(name: firstName),
                const SizedBox(height: 20),
                accountAsync.when(
                  data: (account) => BalanceCard(account: account),
                  loading: () => const _BalanceLoading(),
                  error: (e, _) => _ErrorBox(message: e.toString()),
                ),
                const SizedBox(height: 28),
                QuickActions(
                  actions: [
                    QuickAction(
                      icon: Icons.swap_horiz,
                      label: 'Transfer',
                      onTap: () => context.push(AppRoutes.transfer),
                    ),
                    QuickAction(
                      icon: Icons.credit_card_outlined,
                      label: 'Buy Cards',
                      onTap: () => context.go(AppRoutes.cards),
                    ),
                    QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'Statements',
                      onTap: () => context.go(AppRoutes.history),
                    ),
                    QuickAction(
                      icon: Icons.menu,
                      label: 'Menu',
                      onTap: () => context.go(AppRoutes.menu),
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
                      onPressed: () => context.go(AppRoutes.history),
                      child: const Text('VIEW ALL'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                txAsync.when(
                  data: (list) => _TxList(items: list),
                  loading: () => const _TxLoading(),
                  error: (e, _) => _ErrorBox(message: e.toString()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _NotificationsButton(
            unread: ref.watch(unreadNotificationCountProvider),
          ),
        ],
      ),
    );
  }
}

class _TxList extends StatelessWidget {
  const _TxList({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          'No transactions yet',
          style: AppTextStyles.bodyMuted,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            TransactionTile(transaction: items[i]),
            if (i != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _BalanceLoading extends StatelessWidget {
  const _BalanceLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textPrimary,
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TxLoading extends StatelessWidget {
  const _TxLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: const CircularProgressIndicator(color: AppColors.gold),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMuted.copyWith(color: AppColors.danger),
      ),
    );
  }
}
