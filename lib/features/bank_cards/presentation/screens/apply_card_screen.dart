import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../receipts/presentation/screens/receipt_screen.dart';
import '../../data/bank_card_catalog.dart';
import '../providers/bank_card_providers.dart';

class ApplyCardScreen extends ConsumerStatefulWidget {
  const ApplyCardScreen({super.key});

  @override
  ConsumerState<ApplyCardScreen> createState() => _ApplyCardScreenState();
}

class _ApplyCardScreenState extends ConsumerState<ApplyCardScreen> {
  BankCardProduct? _selected;

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(bankCardActionsProvider);
    final balance = ref
            .watch(accountStreamProvider)
            .valueOrNull
            ?.currentBalance ??
        0;
    final canSubmit = _selected != null &&
        !action.isLoading &&
        balance >= (_selected?.issuanceFee ?? 0);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Apply for a card'),
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
                Tab(text: 'Local (Yaqeen)'),
                Tab(text: 'International'),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        const _YaqeenBanner(),
                        Expanded(
                          child: _CardList(
                            products: BankCardCatalog.local,
                            selected: _selected,
                            onSelect: (p) => setState(() => _selected = p),
                          ),
                        ),
                      ],
                    ),
                    _CardList(
                      products: BankCardCatalog.international,
                      selected: _selected,
                      onSelect: (p) => setState(() => _selected = p),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryRow(
                      label: 'Available balance',
                      value: Formatters.money(balance),
                    ),
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: 'Issuance fee',
                      value: _selected == null
                          ? '—'
                          : Formatters.money(_selected!.issuanceFee),
                      emphasize: true,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: canSubmit ? _submit : null,
                      child: action.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selected == null
                                  ? 'Choose a card'
                                  : 'Apply for ${_selected!.brand}',
                            ),
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

  Future<void> _submit() async {
    final product = _selected!;
    final user = ref.read(currentUserProvider);
    final holderName = user?.displayName ??
        (user?.email.split('@').first ?? 'Cardholder');

    final result = await ref.read(bankCardActionsProvider.notifier).apply(
          product: product,
          holderName: holderName,
        );

    if (!mounted) return;
    final state = ref.read(bankCardActionsProvider);
    if (state.hasError || result == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Application failed: ${state.error?.toString().replaceFirst('Exception: ', '') ?? 'Unknown error'}',
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.pop();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          kind: ReceiptKind.cardApplication,
          title: '${result.brand} application',
          amount: result.fee,
          reference: result.cardId,
          timestamp: DateTime.now(),
          statusLabel: 'Pending',
          statusColor: AppColors.gold,
          rows: [
            ReceiptRow(label: 'Card', value: result.brand),
            ReceiptRow(label: 'Ending in', value: result.last4),
            ReceiptRow(label: 'Valid thru', value: result.expiry),
            ReceiptRow(
              label: 'Cardholder',
              value: holderName,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({
    required this.products,
    required this.selected,
    required this.onSelect,
  });

  final List<BankCardProduct> products;
  final BankCardProduct? selected;
  final ValueChanged<BankCardProduct> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: products.length,
      separatorBuilder: (_, i) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = products[i];
        final isSelected = selected?.id == p.id;
        return InkWell(
          onTap: () => onSelect(p),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.gold : AppColors.divider,
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: p.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.credit_card,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.brand,
                          style:
                              AppTextStyles.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(p.tagline, style: AppTextStyles.bodyMuted),
                      const SizedBox(height: 6),
                      Text(
                        'Issuance fee ${Formatters.money(p.issuanceFee)}',
                        style: AppTextStyles.bodyMuted.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.gold
                      : AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _YaqeenBanner extends StatelessWidget {
  const _YaqeenBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [YaqeenBrand.navy, Color(0xFF1B2661)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: YaqeenBrand.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Y',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  YaqeenBrand.wordmarkArabic,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Yaqeen Bank · ${YaqeenBrand.tagline}',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: Colors.white70,
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        Text(
          value,
          style: emphasize
              ? AppTextStyles.title.copyWith(fontSize: 16)
              : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
