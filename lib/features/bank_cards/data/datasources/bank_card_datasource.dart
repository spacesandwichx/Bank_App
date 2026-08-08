import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../home/data/models/transaction_model.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../bank_card_catalog.dart';
import '../models/bank_card_model.dart';

class BankCardDataSource {
  BankCardDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  final Random _random = Random.secure();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _cardCol(String uid) =>
      _userDoc(uid).collection('bankCards');

  CollectionReference<Map<String, dynamic>> _txCol(String uid) =>
      _userDoc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> _notifCol(String uid) =>
      _userDoc(uid).collection('notifications');

  Stream<List<BankCardModel>> watchCards(String uid) {
    return _cardCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BankCardModel.fromDoc).toList());
  }

  String _generateLast4() {
    return List.generate(4, (_) => _random.nextInt(10)).join();
  }

  String _generateExpiry() {
    final now = DateTime.now();
    final expiryYear = now.year + 4;
    final month = now.month.toString().padLeft(2, '0');
    return '$month/${expiryYear.toString().substring(2)}';
  }

  /// Applies for a new bank card. Debits issuance fee, writes card,
  /// transaction, and notification atomically.
  Future<({String cardId, String last4, String expiry})> applyForCard({
    required String uid,
    required String holderName,
    required BankCardProduct product,
  }) async {
    final last4 = _generateLast4();
    final expiry = _generateExpiry();
    final cardRef = _cardCol(uid).doc();

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(_userDoc(uid));
      final balance =
          (userSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0;
      if (balance < product.issuanceFee) {
        throw Exception('Insufficient balance for issuance fee');
      }

      tx.update(_userDoc(uid), {
        'currentBalance': balance - product.issuanceFee,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        cardRef,
        BankCardModel.toCreateMap(
          product: product,
          holderName: holderName,
          last4: last4,
          expiry: expiry,
        ),
      );

      tx.set(
        _txCol(uid).doc(),
        TransactionModel.toCreateMap(
          merchant: '${product.brand} · issuance fee',
          amount: product.issuanceFee,
          direction: TransactionDirection.outgoing,
          type: TransactionType.other,
          description: 'Card application fee',
        ),
      );

      tx.set(
        _notifCol(uid).doc(),
        NotificationModel.toCreateMap(
          title: 'Card application received',
          body: '${product.brand} · ending $last4 is being processed',
          type: NotificationType.other,
          amount: product.issuanceFee,
        ),
      );
    });

    return (cardId: cardRef.id, last4: last4, expiry: expiry);
  }
}
