import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class AccountRemoteDataSource {
  AccountRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  final Random _random = Random.secure();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _txCol(String uid) =>
      _userDoc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> _notifCol(String uid) =>
      _userDoc(uid).collection('notifications');

  DocumentReference<Map<String, dynamic>> _directoryDoc(String accountNumber) =>
      _firestore.collection('directory').doc(accountNumber);

  String _generateAccountNumber() {
    // 10-digit account number.
    final buffer = StringBuffer();
    for (var i = 0; i < 10; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }

  Future<void> bootstrapIfMissing({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    final userSnap = await _userDoc(uid).get();
    final name = displayName ?? email.split('@').first;

    if (!userSnap.exists) {
      final accountNumber = _generateAccountNumber();
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      batch.set(_userDoc(uid), {
        'email': email,
        'displayName': name,
        'accountNumber': accountNumber,
        'currentBalance': 5000.00,
        'savingsBalance': 1250.00,
        'createdAt': now,
        'updatedAt': now,
      });

      batch.set(_directoryDoc(accountNumber), {
        'uid': uid,
        'displayName': name,
        'accountNumber': accountNumber,
      });

      batch.set(
        _txCol(uid).doc(),
        TransactionModel.toCreateMap(
          merchant: 'Welcome Bonus',
          amount: 5000.00,
          direction: TransactionDirection.incoming,
          type: TransactionType.deposit,
          description: 'Initial account opening credit',
        ),
      );

      batch.set(
        _notifCol(uid).doc(),
        NotificationModel.toCreateMap(
          title: 'Welcome to Al Yaqeen Bank',
          body: 'Your account has been credited with your welcome bonus.',
          type: NotificationType.deposit,
          amount: 5000.00,
        ),
      );

      await batch.commit();
      return;
    }

    final data = userSnap.data() ?? const <String, dynamic>{};
    if (data['accountNumber'] == null) {
      final accountNumber = _generateAccountNumber();
      final batch = _firestore.batch();
      batch.update(_userDoc(uid), {'accountNumber': accountNumber});
      batch.set(_directoryDoc(accountNumber), {
        'uid': uid,
        'displayName': data['displayName'] ?? name,
        'accountNumber': accountNumber,
      });
      await batch.commit();
    }
  }

  Stream<AccountModel> watchAccount(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data() ?? const <String, dynamic>{};
      return AccountModel.fromMap(data);
    });
  }

  Stream<List<TransactionModel>> watchTransactions(
    String uid, {
    int? limit,
  }) {
    Query<Map<String, dynamic>> query =
        _txCol(uid).orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromDoc).toList());
  }

  Future<String> purchase({
    required String uid,
    required String merchant,
    required double amount,
    required TransactionType type,
    String? description,
  }) async {
    final txRef = _txCol(uid).doc();
    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(_userDoc(uid));
      final data = userSnap.data() ?? const <String, dynamic>{};
      final current = (data['currentBalance'] as num?)?.toDouble() ?? 0;
      if (current < amount) {
        throw Exception('Insufficient balance');
      }
      tx.update(_userDoc(uid), {
        'currentBalance': current - amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(
        txRef,
        TransactionModel.toCreateMap(
          merchant: merchant,
          amount: amount,
          direction: TransactionDirection.outgoing,
          type: type,
          description: description,
        ),
      );

      tx.set(
        _notifCol(uid).doc(),
        NotificationModel.toCreateMap(
          title: type == TransactionType.cardPurchase
              ? 'Card purchased'
              : 'Payment sent',
          body: '$merchant · debited',
          type: type == TransactionType.cardPurchase
              ? NotificationType.cardPurchase
              : NotificationType.other,
          amount: amount,
        ),
      );
    });
    return txRef.id;
  }

  Future<({String recipientUid, String recipientName})> lookupAccount(
    String accountNumber,
  ) async {
    final snap = await _directoryDoc(accountNumber).get();
    if (!snap.exists) {
      throw Exception('Account not found');
    }
    final data = snap.data()!;
    return (
      recipientUid: data['uid'] as String,
      recipientName: (data['displayName'] as String?) ?? 'User',
    );
  }

  Future<({String recipientName, String txId})> transfer({
    required String senderUid,
    required String recipientAccountNumber,
    required double amount,
    String? note,
  }) async {
    final directorySnap =
        await _directoryDoc(recipientAccountNumber).get();
    if (!directorySnap.exists) {
      throw Exception('Account number not found');
    }
    final recipientUid = directorySnap.data()!['uid'] as String;
    final recipientName =
        (directorySnap.data()!['displayName'] as String?) ?? 'User';

    if (recipientUid == senderUid) {
      throw Exception('You cannot transfer to your own account');
    }

    final senderSnap = await _userDoc(senderUid).get();
    final senderName =
        (senderSnap.data()?['displayName'] as String?) ?? 'User';

    final senderTxRef = _txCol(senderUid).doc();

    await _firestore.runTransaction((tx) async {
      final freshSender = await tx.get(_userDoc(senderUid));
      final senderBalance =
          (freshSender.data()?['currentBalance'] as num?)?.toDouble() ?? 0;
      if (senderBalance < amount) {
        throw Exception('Insufficient balance');
      }

      tx.update(_userDoc(senderUid), {
        'currentBalance': senderBalance - amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Credit recipient using increment — works without reading recipient doc.
      tx.update(_userDoc(recipientUid), {
        'currentBalance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        senderTxRef,
        TransactionModel.toCreateMap(
          merchant: 'Transfer to $recipientName',
          amount: amount,
          direction: TransactionDirection.outgoing,
          type: TransactionType.transfer,
          description: note,
        ),
      );

      tx.set(
        _txCol(recipientUid).doc(),
        TransactionModel.toCreateMap(
          merchant: 'Transfer from $senderName',
          amount: amount,
          direction: TransactionDirection.incoming,
          type: TransactionType.transfer,
          description: note,
        ),
      );

      tx.set(
        _notifCol(senderUid).doc(),
        NotificationModel.toCreateMap(
          title: 'Transfer sent',
          body: 'Sent to $recipientName',
          type: NotificationType.transferSent,
          amount: amount,
        ),
      );

      tx.set(
        _notifCol(recipientUid).doc(),
        NotificationModel.toCreateMap(
          title: 'Money received',
          body: 'From $senderName',
          type: NotificationType.transferReceived,
          amount: amount,
        ),
      );
    });

    return (recipientName: recipientName, txId: senderTxRef.id);
  }

  Stream<List<NotificationModel>> watchNotifications(String uid, {int? limit}) {
    Query<Map<String, dynamic>> query =
        _notifCol(uid).orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromDoc).toList());
  }

  Future<void> markNotificationRead(String uid, String notificationId) {
    return _notifCol(uid).doc(notificationId).update({'read': true});
  }

  Future<void> markAllNotificationsRead(String uid) async {
    final unread =
        await _notifCol(uid).where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
