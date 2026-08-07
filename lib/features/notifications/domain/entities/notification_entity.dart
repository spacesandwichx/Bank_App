enum NotificationType {
  cardPurchase,
  transferSent,
  transferReceived,
  deposit,
  other,
}

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.amount,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final double? amount;
  final bool read;
  final DateTime createdAt;
}
