import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/bank_card_catalog.dart';
import '../../data/datasources/bank_card_datasource.dart';
import '../../data/models/bank_card_model.dart';

final bankCardDataSourceProvider = Provider<BankCardDataSource>((ref) {
  return BankCardDataSource(ref.watch(firestoreProvider));
});

final bankCardsStreamProvider =
    StreamProvider<List<BankCardModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(bankCardDataSourceProvider).watchCards(uid);
});

class BankCardApplicationResult {
  const BankCardApplicationResult({
    required this.cardId,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.fee,
  });

  final String cardId;
  final String brand;
  final String last4;
  final String expiry;
  final double fee;
}

class BankCardActionsController
    extends StateNotifier<AsyncValue<void>> {
  BankCardActionsController(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<BankCardApplicationResult?> apply({
    required BankCardProduct product,
    required String holderName,
  }) async {
    final uid = _ref.read(authStateProvider).value?.uid;
    if (uid == null) return null;
    state = const AsyncValue.loading();
    BankCardApplicationResult? result;
    state = await AsyncValue.guard(() async {
      final res = await _ref.read(bankCardDataSourceProvider).applyForCard(
            uid: uid,
            holderName: holderName,
            product: product,
          );
      result = BankCardApplicationResult(
        cardId: res.cardId,
        brand: product.brand,
        last4: res.last4,
        expiry: res.expiry,
        fee: product.issuanceFee,
      );
    });
    return state.hasError ? null : result;
  }
}

final bankCardActionsProvider = StateNotifierProvider<
    BankCardActionsController, AsyncValue<void>>((ref) {
  return BankCardActionsController(ref);
});
