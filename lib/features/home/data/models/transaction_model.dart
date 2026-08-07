import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.merchant,
    required super.amount,
    required super.date,
    required super.direction,
    required super.type,
    super.description,
  });

  factory TransactionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return TransactionModel(
      id: doc.id,
      merchant: data['merchant'] as String? ?? 'Unknown',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      direction: _parseDirection(data['direction'] as String?),
      type: _parseType(data['type'] as String?),
      description: data['description'] as String?,
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String merchant,
    required double amount,
    required TransactionDirection direction,
    required TransactionType type,
    String? description,
  }) {
    return {
      'merchant': merchant,
      'amount': amount,
      'direction': direction.name,
      'type': type.name,
      'description': ?description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static TransactionDirection _parseDirection(String? value) {
    return TransactionDirection.values.firstWhere(
      (d) => d.name == value,
      orElse: () => TransactionDirection.outgoing,
    );
  }

  static TransactionType _parseType(String? value) {
    return TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => TransactionType.other,
    );
  }
}
