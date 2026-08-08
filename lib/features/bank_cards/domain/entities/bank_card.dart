import 'package:flutter/material.dart';

enum BankCardNetwork { visa, mastercard }

enum BankCardType { debit, credit }

enum BankCardScope { local, international }

enum BankCardStatus { pending, active, blocked }

class BankCard {
  const BankCard({
    required this.id,
    required this.brand,
    required this.network,
    required this.type,
    required this.scope,
    required this.status,
    required this.last4,
    required this.holderName,
    required this.expiry,
    required this.issuanceFee,
    required this.appliedAt,
    required this.gradient,
    this.issuerWordmark,
  });

  final String id;
  final String brand;
  final BankCardNetwork network;
  final BankCardType type;
  final BankCardScope scope;
  final BankCardStatus status;
  final String last4;
  final String holderName;
  final String expiry;
  final double issuanceFee;
  final DateTime appliedAt;
  final List<Color> gradient;
  final String? issuerWordmark;
}
