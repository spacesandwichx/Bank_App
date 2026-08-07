import 'package:flutter/material.dart';

class GiftCard {
  const GiftCard({
    required this.id,
    required this.brand,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.denominations,
  });

  final String id;
  final String brand;
  final String tagline;
  final IconData icon;
  final Color color;
  final List<double> denominations;
}
