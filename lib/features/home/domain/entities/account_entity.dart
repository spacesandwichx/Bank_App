class AccountEntity {
  const AccountEntity({
    required this.totalBalance,
    required this.currentBalance,
    required this.savingsBalance,
    required this.accountNumber,
    required this.holderName,
  });

  final double totalBalance;
  final double currentBalance;
  final double savingsBalance;
  final String accountNumber;
  final String holderName;

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
  }
}
