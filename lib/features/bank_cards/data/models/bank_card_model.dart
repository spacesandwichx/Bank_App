import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/bank_card.dart';
import '../bank_card_catalog.dart';

class BankCardModel extends BankCard {
  const BankCardModel({
    required super.id,
    required super.brand,
    required super.network,
    required super.type,
    required super.scope,
    required super.status,
    required super.last4,
    required super.holderName,
    required super.expiry,
    required super.issuanceFee,
    required super.appliedAt,
    required super.gradient,
    super.issuerWordmark,
    required this.productId,
  });

  final String productId;

  factory BankCardModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    final productId = data['productId'] as String? ?? '';
    final product = _lookupProduct(productId);
    return BankCardModel(
      id: doc.id,
      productId: productId,
      brand: data['brand'] as String? ?? product?.brand ?? 'Bank Card',
      network: _parseNetwork(data['network'] as String?),
      type: _parseType(data['type'] as String?),
      scope: _parseScope(data['scope'] as String?),
      status: _parseStatus(data['status'] as String?),
      last4: data['last4'] as String? ?? '0000',
      holderName: data['holderName'] as String? ?? '',
      expiry: data['expiry'] as String? ?? '',
      issuanceFee: (data['issuanceFee'] as num?)?.toDouble() ?? 0,
      appliedAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gradient: product?.gradient ?? const [],
      issuerWordmark: product?.issuerWordmark,
    );
  }

  static Map<String, dynamic> toCreateMap({
    required BankCardProduct product,
    required String holderName,
    required String last4,
    required String expiry,
  }) {
    return {
      'productId': product.id,
      'brand': product.brand,
      'network': product.network.name,
      'type': product.type.name,
      'scope': product.scope.name,
      'status': BankCardStatus.pending.name,
      'last4': last4,
      'holderName': holderName,
      'expiry': expiry,
      'issuanceFee': product.issuanceFee,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static BankCardProduct? _lookupProduct(String id) {
    try {
      return BankCardCatalog.byId(id);
    } catch (_) {
      return null;
    }
  }

  static BankCardNetwork _parseNetwork(String? value) {
    return BankCardNetwork.values.firstWhere(
      (v) => v.name == value,
      orElse: () => BankCardNetwork.visa,
    );
  }

  static BankCardType _parseType(String? value) {
    return BankCardType.values.firstWhere(
      (v) => v.name == value,
      orElse: () => BankCardType.debit,
    );
  }

  static BankCardScope _parseScope(String? value) {
    return BankCardScope.values.firstWhere(
      (v) => v.name == value,
      orElse: () => BankCardScope.local,
    );
  }

  static BankCardStatus _parseStatus(String? value) {
    return BankCardStatus.values.firstWhere(
      (v) => v.name == value,
      orElse: () => BankCardStatus.pending,
    );
  }
}
