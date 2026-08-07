class AccountEntity {
  const AccountEntity({
    required this.totalBalance,
    required this.currentBalance,
    required this.savingsBalance,
  });

  final double totalBalance;
  final double currentBalance;
  final double savingsBalance;
}
