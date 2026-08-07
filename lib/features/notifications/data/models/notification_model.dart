import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.amount,
    required super.read,
    required super.createdAt,
  });

  factory NotificationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: _parseType(data['type'] as String?),
      amount: (data['amount'] as num?)?.toDouble(),
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String title,
    required String body,
    required NotificationType type,
    double? amount,
  }) {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'amount': ?amount,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static NotificationType _parseType(String? value) {
    return NotificationType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => NotificationType.other,
    );
  }
}
