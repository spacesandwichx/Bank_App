enum ChequeStatus { pending, issued, cancelled }

class ChequeRequest {
  const ChequeRequest({
    required this.id,
    required this.number,
    required this.payeeName,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String number;
  final String payeeName;
  final double amount;
  final ChequeStatus status;
  final DateTime createdAt;
  final String? note;
}
