import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.totalBalance,
    required super.currentBalance,
    required super.savingsBalance,
    required super.accountNumber,
    required super.holderName,
  });

  factory AccountModel.fromMap(Map<String, dynamic> data) {
    final current = (data['currentBalance'] as num?)?.toDouble() ?? 0;
    final savings = (data['savingsBalance'] as num?)?.toDouble() ?? 0;
    final accountNumber = data['accountNumber'] as String? ?? '';
    final holder = data['displayName'] as String? ??
        (data['email'] as String?)?.split('@').first ??
        'Account Holder';
    return AccountModel(
      totalBalance: current + savings,
      currentBalance: current,
      savingsBalance: savings,
      accountNumber: accountNumber,
      holderName: holder,
    );
  }
}
