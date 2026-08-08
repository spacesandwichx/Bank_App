import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/bank_card.dart';

class BankCardVisual extends StatelessWidget {
  const BankCardVisual({
    super.key,
    required this.brand,
    required this.network,
    required this.last4,
    required this.holderName,
    required this.expiry,
    required this.gradient,
    this.issuerWordmark,
  });

  final String brand;
  final BankCardNetwork network;
  final String last4;
  final String holderName;
  final String expiry;
  final List<Color> gradient;
  final String? issuerWordmark;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.isEmpty
                ? const [Color(0xFF1A2332), Color(0xFF3A4657)]
                : gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: issuerWordmark != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issuerWordmark!,
                              textDirection: TextDirection.rtl,
                              style: AppTextStyles.title.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'YAQEEN BANK',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'AL YAQEEN BANK',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                ),
                Text(
                  _networkLabel(network),
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '•••• •••• •••• $last4',
              style: AppTextStyles.title.copyWith(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CARDHOLDER',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white54)),
                      const SizedBox(height: 2),
                      Text(
                        holderName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('VALID THRU',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white54)),
                    const SizedBox(height: 2),
                    Text(
                      expiry,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _networkLabel(BankCardNetwork n) {
    switch (n) {
      case BankCardNetwork.visa:
        return 'VISA';
      case BankCardNetwork.mastercard:
        return 'mastercard';
    }
  }
}
