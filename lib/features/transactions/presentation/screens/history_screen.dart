import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/transaction_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(allTransactionsStreamProvider);
    ref.invalidate(recentTransactionsStreamProvider);
    ref.invalidate(accountStreamProvider);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(allTransactionsStreamProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.background,
              child: const TabBar(
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
                  Tab(text: 'All'),
                  Tab(text: 'Incoming'),
                  Tab(text: 'Outgoing'),
                ],
              ),
            ),
          ),
        ),
        body: txAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, _) => AppRefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load history\n$e',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted
                            .copyWith(color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (all) {
            final incoming = all
                .where((t) => t.direction == TransactionDirection.incoming)
                .toList();
            final outgoing = all
                .where((t) => t.direction == TransactionDirection.outgoing)
                .toList();
            return TabBarView(
              children: [
                _TransactionList(
                    items: all, onRefresh: () => _refresh(ref)),
                _TransactionList(
                    items: incoming, onRefresh: () => _refresh(ref)),
                _TransactionList(
                    items: outgoing, onRefresh: () => _refresh(ref)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.items, required this.onRefresh});

  final List<TransactionEntity> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No transactions here yet',
                        style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDay(items);
    final dayKeys = grouped.keys.toList();

    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: dayKeys.length,
        itemBuilder: (context, i) {
          final key = dayKeys[i];
          final dayItems = grouped[key]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _headerFor(key),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    for (var j = 0; j < dayItems.length; j++) ...[
                      TransactionTile(transaction: dayItems[j]),
                      if (j != dayItems.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<TransactionEntity>> _groupByDay(
      List<TransactionEntity> items) {
    final map = <DateTime, List<TransactionEntity>>{};
    for (final t in items) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  String _headerFor(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'TODAY';
    if (day == yesterday) return 'YESTERDAY';
    return DateFormat('EEEE, MMM d').format(day).toUpperCase();
  }
}
