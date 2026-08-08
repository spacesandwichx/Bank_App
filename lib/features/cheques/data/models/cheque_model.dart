import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cheque_request.dart';

class ChequeModel extends ChequeRequest {
  const ChequeModel({
    required super.id,
    required super.number,
    required super.payeeName,
    required super.amount,
    required super.status,
    required super.createdAt,
    super.note,
  });

  factory ChequeModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return ChequeModel(
      id: doc.id,
      number: data['number'] as String? ?? '',
      payeeName: data['payeeName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(data['status'] as String?),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String number,
    required String payeeName,
    required double amount,
    String? note,
  }) {
    return {
      'number': number,
      'payeeName': payeeName,
      'amount': amount,
      'status': ChequeStatus.pending.name,
      'note': ?note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static ChequeStatus _parseStatus(String? value) {
    return ChequeStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ChequeStatus.pending,
    );
  }
}
