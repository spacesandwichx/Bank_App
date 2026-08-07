import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';

// Mock providers for now — data layer will replace with real Dio/Firestore.
final accountProvider = Provider<AccountEntity>((ref) {
  return const AccountEntity(
    totalBalance: 4250.00,
    currentBalance: 3000.00,
    savingsBalance: 1250.00,
  );
});

final recentTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final now = DateTime.now();
  return [
    TransactionEntity(
      id: '1',
      merchant: 'Al Madina Supermarket',
      amount: 145.50,
      date: now.subtract(const Duration(hours: 3)),
      direction: TransactionDirection.outgoing,
    ),
    TransactionEntity(
      id: '2',
      merchant: 'Salary Deposit',
      amount: 3500.00,
      date: now.subtract(const Duration(days: 1)),
      direction: TransactionDirection.incoming,
    ),
    TransactionEntity(
      id: '3',
      merchant: 'Libyana Recharge',
      amount: 20.00,
      date: now.subtract(const Duration(days: 3)),
      direction: TransactionDirection.outgoing,
    ),
    TransactionEntity(
      id: '4',
      merchant: 'Cafe Milano',
      amount: 15.00,
      date: now.subtract(const Duration(days: 4)),
      direction: TransactionDirection.outgoing,
    ),
  ];
});
