import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._remote);

  final AccountRemoteDataSource _remote;

  @override
  Future<void> bootstrap({
    required String uid,
    required String email,
    String? displayName,
  }) {
    return _remote.bootstrapIfMissing(
      uid: uid,
      email: email,
      displayName: displayName,
    );
  }

  @override
  Stream<AccountEntity> watchAccount(String uid) => _remote.watchAccount(uid);

  @override
  Stream<List<TransactionEntity>> watchTransactions(String uid, {int? limit}) =>
      _remote.watchTransactions(uid, limit: limit);

  @override
  Future<void> purchase({
    required String uid,
    required String merchant,
    required double amount,
    required TransactionType type,
    String? description,
  }) {
    return _remote.purchase(
      uid: uid,
      merchant: merchant,
      amount: amount,
      type: type,
      description: description,
    );
  }

  @override
  Future<String> transfer({
    required String senderUid,
    required String recipientAccountNumber,
    required double amount,
    String? note,
  }) {
    return _remote.transfer(
      senderUid: senderUid,
      recipientAccountNumber: recipientAccountNumber,
      amount: amount,
      note: note,
    );
  }
}
