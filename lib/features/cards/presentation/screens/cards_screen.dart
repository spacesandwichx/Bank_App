import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/gift_card_catalog.dart';
import '../../domain/entities/gift_card.dart';
import '../widgets/gift_card_tile.dart';
import '../widgets/purchase_sheet.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountStreamProvider);
    final balance = accountAsync.maybeWhen(
      data: (a) => a.currentBalance,
      orElse: () => 0.0,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buy Cards'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.gold,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              tabs: [
                Tab(text: 'Local'),
                Tab(text: 'International'),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _BalancePill(balance: balance),
              Expanded(
                child: TabBarView(
                  children: [
                    _CardsGrid(
                      cards: GiftCardCatalog.local,
                      onRefresh: () async {
                        ref.invalidate(accountStreamProvider);
                        await Future.delayed(
                            const Duration(milliseconds: 400));
                      },
                    ),
                    _CardsGrid(
                      cards: GiftCardCatalog.international,
                      onRefresh: () async {
                        ref.invalidate(accountStreamProvider);
                        await Future.delayed(
                            const Duration(milliseconds: 400));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  const _CardsGrid({required this.cards, required this.onRefresh});

  final List<GiftCard> cards;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.92,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return GiftCardTile(
            card: card,
            onTap: () => _openPurchase(context, card),
          );
        },
      ),
    );
  }

  void _openPurchase(BuildContext context, GiftCard card) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PurchaseSheet(card: card),
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
}
