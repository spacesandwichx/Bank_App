import 'package:flutter/material.dart';

import '../domain/entities/bank_card.dart';

/// Yaqeen Bank brand palette (from yaqeenbank.ly).
class YaqeenBrand {
  YaqeenBrand._();

  static const Color navy = Color(0xFF0B1338);
  static const Color orange = Color(0xFFF47D3F);
  static const String wordmarkArabic = 'مصرف اليقين';
  static const String tagline = 'ثقة تُبنى وتدوم';
}

class BankCardProduct {
  const BankCardProduct({
    required this.id,
    required this.brand,
    required this.network,
    required this.type,
    required this.scope,
    required this.issuanceFee,
    required this.tagline,
    required this.gradient,
    this.issuerWordmark,
  });

  final String id;
  final String brand;
  final BankCardNetwork network;
  final BankCardType type;
  final BankCardScope scope;
  final double issuanceFee;
  final String tagline;
  final List<Color> gradient;

  /// Optional wordmark shown on the card face instead of the generic bank name.
  final String? issuerWordmark;
}

class BankCardCatalog {
  BankCardCatalog._();

  static const List<BankCardProduct> local = [
    BankCardProduct(
      id: 'yaqeen_visa_debit',
      brand: 'Yaqeen Bank Visa Debit',
      network: BankCardNetwork.visa,
      type: BankCardType.debit,
      scope: BankCardScope.local,
      issuanceFee: 5.00,
      tagline: 'Everyday debit for Libyan merchants and ATMs.',
      gradient: [YaqeenBrand.navy, Color(0xFF1B2661)],
      issuerWordmark: YaqeenBrand.wordmarkArabic,
    ),
    BankCardProduct(
      id: 'yaqeen_mastercard_debit',
      brand: 'Yaqeen Bank Mastercard Debit',
      network: BankCardNetwork.mastercard,
      type: BankCardType.debit,
      scope: BankCardScope.local,
      issuanceFee: 5.00,
      tagline: 'Accepted at every Yaqeen POS across Libya.',
      gradient: [YaqeenBrand.navy, Color(0xFF2A3572)],
      issuerWordmark: YaqeenBrand.wordmarkArabic,
    ),
    BankCardProduct(
      id: 'yaqeen_visa_credit',
      brand: 'Yaqeen Bank Visa Credit',
      network: BankCardNetwork.visa,
      type: BankCardType.credit,
      scope: BankCardScope.local,
      issuanceFee: 15.00,
      tagline: 'Local credit line with Yaqeen rewards.',
      gradient: [YaqeenBrand.navy, YaqeenBrand.orange],
      issuerWordmark: YaqeenBrand.wordmarkArabic,
    ),
  ];

  static const List<BankCardProduct> international = [
    BankCardProduct(
      id: 'intl_visa_platinum',
      brand: 'Visa Platinum',
      network: BankCardNetwork.visa,
      type: BankCardType.credit,
      scope: BankCardScope.international,
      issuanceFee: 25.00,
      tagline: 'Global acceptance and travel benefits.',
      gradient: [Color(0xFF1A1F71), Color(0xFF3B41A1)],
    ),
    BankCardProduct(
      id: 'intl_mastercard_world',
      brand: 'Mastercard World',
      network: BankCardNetwork.mastercard,
      type: BankCardType.credit,
      scope: BankCardScope.international,
      issuanceFee: 25.00,
      tagline: 'Priceless privileges worldwide.',
      gradient: [Color(0xFFEB001B), Color(0xFFF79E1B)],
    ),
    BankCardProduct(
      id: 'intl_visa_signature',
      brand: 'Visa Signature',
      network: BankCardNetwork.visa,
      type: BankCardType.credit,
      scope: BankCardScope.international,
      issuanceFee: 40.00,
      tagline: 'Premium concierge and lounge access.',
      gradient: [Color(0xFFC59B27), Color(0xFF8A6A10)],
    ),
  ];

  static BankCardProduct byId(String id) {
    return [...local, ...international].firstWhere((p) => p.id == id);
  }
}
