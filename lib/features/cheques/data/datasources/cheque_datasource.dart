import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../home/data/models/transaction_model.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../models/cheque_model.dart';

class ChequeDataSource {
  ChequeDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  final Random _random = Random.secure();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _chequeCol(String uid) =>
      _userDoc(uid).collection('cheques');

  CollectionReference<Map<String, dynamic>> _txCol(String uid) =>
      _userDoc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> _notifCol(String uid) =>
      _userDoc(uid).collection('notifications');

  Stream<List<ChequeModel>> watchCheques(String uid) {
    return _chequeCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChequeModel.fromDoc).toList());
  }

  String _generateChequeNumber() {
    final buffer = StringBuffer('CHQ-');
    for (var i = 0; i < 8; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }

  Future<({String chequeId, String number})> requestCheque({
    required String uid,
    required String payeeName,
    required double amount,
    String? note,
  }) async {
    final number = _generateChequeNumber();
    final chequeRef = _chequeCol(uid).doc();

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(_userDoc(uid));
      final balance =
          (userSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0;
      if (balance < amount) {
        throw Exception('Insufficient balance');
      }

      tx.update(_userDoc(uid), {
        'currentBalance': balance - amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        chequeRef,
        ChequeModel.toCreateMap(
          number: number,
          payeeName: payeeName,
          amount: amount,
          note: note,
        ),
      );

      tx.set(
        _txCol(uid).doc(),
        TransactionModel.toCreateMap(
          merchant: 'Cheque · $payeeName',
          amount: amount,
          direction: TransactionDirection.outgoing,
          type: TransactionType.other,
          description: 'Cheque $number',
        ),
      );

      tx.set(
        _notifCol(uid).doc(),
        NotificationModel.toCreateMap(
          title: 'Cheque issued',
          body: '$number to $payeeName',
          type: NotificationType.other,
          amount: amount,
        ),
      );
    });

    return (chequeId: chequeRef.id, number: number);
  }
}
