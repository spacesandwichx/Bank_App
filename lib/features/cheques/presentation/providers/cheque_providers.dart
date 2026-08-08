import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/datasources/cheque_datasource.dart';
import '../../data/models/cheque_model.dart';

final chequeDataSourceProvider = Provider<ChequeDataSource>((ref) {
  return ChequeDataSource(ref.watch(firestoreProvider));
});

final chequesStreamProvider = StreamProvider<List<ChequeModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(chequeDataSourceProvider).watchCheques(uid);
});

class ChequeApplicationResult {
  const ChequeApplicationResult({
    required this.chequeId,
    required this.number,
    required this.payeeName,
    required this.amount,
    this.note,
  });

  final String chequeId;
  final String number;
  final String payeeName;
  final double amount;
  final String? note;
}

class ChequeActionsController extends StateNotifier<AsyncValue<void>> {
  ChequeActionsController(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<ChequeApplicationResult?> request({
    required String payeeName,
    required double amount,
    String? note,
  }) async {
    final uid = _ref.read(authStateProvider).value?.uid;
    if (uid == null) return null;
    state = const AsyncValue.loading();
    ChequeApplicationResult? result;
    state = await AsyncValue.guard(() async {
      final res = await _ref.read(chequeDataSourceProvider).requestCheque(
            uid: uid,
            payeeName: payeeName,
            amount: amount,
            note: note,
          );
      result = ChequeApplicationResult(
        chequeId: res.chequeId,
        number: res.number,
        payeeName: payeeName,
        amount: amount,
        note: note,
      );
    });
    return state.hasError ? null : result;
  }
}

final chequeActionsProvider =
    StateNotifierProvider<ChequeActionsController, AsyncValue<void>>(
        (ref) => ChequeActionsController(ref));
