import '../entities/account_entity.dart';
import '../entities/transaction_entity.dart';

abstract class AccountRepository {
  Future<void> bootstrap({
    required String uid,
    required String email,
    String? displayName,
  });

  Stream<AccountEntity> watchAccount(String uid);

  Stream<List<TransactionEntity>> watchTransactions(String uid, {int? limit});

  Future<String> purchase({
    required String uid,
    required String merchant,
    required double amount,
    required TransactionType type,
    String? description,
  });

  Future<({String recipientName, String txId})> transfer({
    required String senderUid,
    required String recipientAccountNumber,
    required double amount,
    String? note,
  });
}
