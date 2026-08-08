import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../domain/entities/bank_card.dart';
import '../providers/bank_card_providers.dart';
import '../widgets/bank_card_visual.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bankCardsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
        actions: [
          IconButton(
            tooltip: 'Apply for card',
            onPressed: () => context.push(AppRoutes.applyCard),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load cards\n$e',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
          data: (cards) {
            return AppRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bankCardsStreamProvider);
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  if (cards.isEmpty)
                    _EmptyState(onApply: () => context.push(AppRoutes.applyCard))
                  else ...[
                    for (final card in cards) ...[
                      _CardEntry(card: card),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.applyCard),
                      icon: const Icon(Icons.add),
                      label: const Text('Apply for a new card'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardEntry extends StatelessWidget {
  const _CardEntry({required this.card});

  final BankCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BankCardVisual(
          brand: card.brand,
          network: card.network,
          last4: card.last4,
          holderName: card.holderName,
          expiry: card.expiry,
          gradient: card.gradient,
          issuerWordmark: card.issuerWordmark,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                card.brand,
                style: AppTextStyles.title.copyWith(fontSize: 15),
              ),
            ),
            _StatusPill(status: card.status),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _subtitle(card),
          style: AppTextStyles.bodyMuted,
        ),
      ],
    );
  }

  String _subtitle(BankCard c) {
    final type = c.type == BankCardType.debit ? 'Debit' : 'Credit';
    final scope =
        c.scope == BankCardScope.local ? 'Local' : 'International';
    return '$scope · $type · ending ${c.last4}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BankCardStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BankCardStatus.pending => ('PENDING', AppColors.gold),
      BankCardStatus.active => ('ACTIVE', AppColors.success),
      BankCardStatus.blocked => ('BLOCKED', AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Icon(Icons.credit_card_off_outlined,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No cards yet', style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text(
            'Apply for a local or international card to get started.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.add),
            label: const Text('Apply for a card'),
          ),
        ],
      ),
    );
  }
}
