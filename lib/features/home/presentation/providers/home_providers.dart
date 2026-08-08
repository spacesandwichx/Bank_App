import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/account_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final accountRemoteDataSourceProvider =
    Provider<AccountRemoteDataSource>((ref) {
  return AccountRemoteDataSource(ref.watch(firestoreProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountRemoteDataSourceProvider));
});

final _currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

final accountStreamProvider = StreamProvider<AccountEntity>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(accountRepositoryProvider).watchAccount(uid);
});

final recentTransactionsStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(accountRepositoryProvider).watchTransactions(uid, limit: 5);
});

final allTransactionsStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(accountRepositoryProvider).watchTransactions(uid);
});

class AccountActionsController extends StateNotifier<AsyncValue<void>> {
  AccountActionsController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<String?> purchase({
    required String merchant,
    required double amount,
    required TransactionType type,
    String? description,
  }) async {
    final uid = _ref.read(_currentUidProvider);
    if (uid == null) return null;
    state = const AsyncValue.loading();
    String? txId;
    state = await AsyncValue.guard(() async {
      txId = await _ref.read(accountRepositoryProvider).purchase(
            uid: uid,
            merchant: merchant,
            amount: amount,
            type: type,
            description: description,
          );
    });
    return state.hasError ? null : txId;
  }

  Future<({String recipientName, String txId})?> transfer({
    required String recipientAccountNumber,
    required double amount,
    String? note,
  }) async {
    final uid = _ref.read(_currentUidProvider);
    if (uid == null) return null;
    state = const AsyncValue.loading();
    ({String recipientName, String txId})? result;
    state = await AsyncValue.guard(() async {
      result = await _ref.read(accountRepositoryProvider).transfer(
            senderUid: uid,
            recipientAccountNumber: recipientAccountNumber,
            amount: amount,
            note: note,
          );
    });
    return state.hasError ? null : result;
  }
}

final accountActionsProvider =
    StateNotifierProvider<AccountActionsController, AsyncValue<void>>((ref) {
  return AccountActionsController(ref);
});
