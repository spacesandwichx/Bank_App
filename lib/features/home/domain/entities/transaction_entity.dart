enum TransactionDirection { incoming, outgoing }

enum TransactionType { transfer, cardPurchase, deposit, other }

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.direction,
    required this.type,
    this.description,
  });

  final String id;
  final String merchant;
  final double amount;
  final DateTime date;
  final TransactionDirection direction;
  final TransactionType type;
  final String? description;
}
