enum TransactionDirection { incoming, outgoing }

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.direction,
  });

  final String id;
  final String merchant;
  final double amount;
  final DateTime date;
  final TransactionDirection direction;
}
