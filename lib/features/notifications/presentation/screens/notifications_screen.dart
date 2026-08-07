import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(notificationsStreamProvider);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsStreamProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationActionsProvider).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: async.when(
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
                        'Could not load notifications\n$e',
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
          data: (items) {
            if (items.isEmpty) {
              return AppRefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_none,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('You have no notifications yet',
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
            final keys = grouped.keys.toList();

            return AppRefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: keys.length,
              itemBuilder: (context, i) {
                final key = keys[i];
                final list = grouped[key]!;
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
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          for (var j = 0; j < list.length; j++) ...[
                            _NotificationRow(notification: list[j]),
                            if (j != list.length - 1)
                              const Divider(height: 1),
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
          },
        ),
      ),
    );
  }

  Map<DateTime, List<NotificationEntity>> _groupByDay(
      List<NotificationEntity> items) {
    final map = <DateTime, List<NotificationEntity>>{};
    for (final n in items) {
      final key = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      map.putIfAbsent(key, () => []).add(n);
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

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification});

  final NotificationEntity notification;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.cardPurchase:
        return Icons.card_giftcard;
      case NotificationType.transferSent:
        return Icons.arrow_upward;
      case NotificationType.transferReceived:
        return Icons.arrow_downward;
      case NotificationType.deposit:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.other:
        return Icons.receipt_long_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.transferReceived:
      case NotificationType.deposit:
        return AppColors.success;
      case NotificationType.transferSent:
      case NotificationType.cardPurchase:
      case NotificationType.other:
        return AppColors.naval;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: notification.read
          ? null
          : () => ref
              .read(notificationActionsProvider)
              .markRead(notification.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 18, color: _iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (notification.amount != null) ...[
                        Text(
                          Formatters.money(notification.amount!),
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: _iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('·', style: AppTextStyles.bodyMuted),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        Formatters.date(notification.createdAt),
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
