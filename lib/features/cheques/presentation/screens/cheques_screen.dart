import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../domain/entities/cheque_request.dart';
import '../providers/cheque_providers.dart';

class ChequesScreen extends ConsumerWidget {
  const ChequesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chequesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Cheques'),
        actions: [
          IconButton(
            tooltip: 'Request cheque',
            onPressed: () => context.push(AppRoutes.applyCheque),
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
                'Could not load cheques\n$e',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted
                    .copyWith(color: AppColors.danger),
              ),
            ),
          ),
          data: (items) {
            return AppRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(chequesStreamProvider);
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  if (items.isEmpty)
                    _EmptyState(
                      onRequest: () =>
                          context.push(AppRoutes.applyCheque),
                    )
                  else ...[
                    for (final c in items) ...[
                      _ChequeTile(cheque: c),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.applyCheque),
                      icon: const Icon(Icons.add),
                      label: const Text('Request a new cheque'),
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

class _ChequeTile extends StatelessWidget {
  const _ChequeTile({required this.cheque});

  final ChequeRequest cheque;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cheque.payeeName,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _StatusPill(status: cheque.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${cheque.number} · ${Formatters.date(cheque.createdAt)}',
                  style: AppTextStyles.bodyMuted,
                ),
                if (cheque.note != null && cheque.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(cheque.note!, style: AppTextStyles.bodyMuted),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.money(cheque.amount),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ChequeStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ChequeStatus.pending => ('PENDING', AppColors.gold),
      ChequeStatus.issued => ('ISSUED', AppColors.success),
      ChequeStatus.cancelled => ('CANCELLED', AppColors.danger),
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
  const _EmptyState({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No cheques yet', style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text(
            'Request a bank cheque payable to any name.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRequest,
            icon: const Icon(Icons.add),
            label: const Text('Request a cheque'),
          ),
        ],
      ),
    );
  }
}
