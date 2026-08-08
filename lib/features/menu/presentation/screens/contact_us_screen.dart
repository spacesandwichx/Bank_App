import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../bank_cards/data/bank_card_catalog.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: const [
            _Header(),
            SizedBox(height: 20),
            _Section(
              title: 'GENERAL ADMINISTRATION',
              arabicTitle: 'الإدارة العامة',
              items: [
                _ContactItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+218 21 3660891',
                ),
                _ContactItem(
                  icon: Icons.print_outlined,
                  label: 'Fax',
                  value: '+218 21 3660891',
                ),
                _ContactItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'info@yaqeenbank.ly',
                ),
                _ContactItem(
                  icon: Icons.mail_outline,
                  label: 'P.O. Box',
                  value: 'YAQBLYLT',
                ),
                _ContactItem(
                  icon: Icons.public,
                  label: 'SWIFT',
                  value: 'YAQBLYLT',
                ),
                _ContactItem(
                  icon: Icons.place_outlined,
                  label: 'Address',
                  value:
                      'طريق الشط – بالقرب من الإشارة الضوئية (سيمافرو الحرية)',
                  isRtl: true,
                ),
              ],
            ),
            SizedBox(height: 16),
            _Section(
              title: 'SHAREHOLDER RELATIONS',
              arabicTitle: 'إدارة علاقات المساهمين',
              items: [
                _ContactItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+218 21 3623501',
                ),
                _ContactItem(
                  icon: Icons.print_outlined,
                  label: 'Fax',
                  value: '+218 21 3660891',
                ),
                _ContactItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'info@yaqeenbank.ly',
                ),
              ],
            ),
            SizedBox(height: 16),
            _Section(
              title: 'FOLLOW US',
              arabicTitle: 'تابعنا',
              items: [
                _ContactItem(
                  icon: Icons.public,
                  label: 'X (Twitter)',
                  value: 'x.com/yaqeenbank',
                ),
                _ContactItem(
                  icon: Icons.facebook_outlined,
                  label: 'Facebook',
                  value: 'facebook.com/Yaqeenbank',
                ),
                _ContactItem(
                  icon: Icons.play_circle_outline,
                  label: 'YouTube',
                  value: 'youtube.com/@yaqeenbank',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [YaqeenBrand.navy, Color(0xFF1B2661)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: YaqeenBrand.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Y',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  YaqeenBrand.wordmarkArabic,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  YaqeenBrand.tagline,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyMuted
                      .copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.arabicTitle,
    required this.items,
  });

  final String title;
  final String arabicTitle;
  final List<_ContactItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.6,
                ),
              ),
              Text(
                arabicTitle,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.bodyMuted
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isRtl = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.naval, size: 18),
      ),
      title: Text(label, style: AppTextStyles.bodyMuted),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          value,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      trailing: IconButton(
        tooltip: 'Copy',
        icon: const Icon(Icons.copy_outlined,
            color: AppColors.gold, size: 18),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('$label copied'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.naval,
                duration: const Duration(seconds: 2),
              ),
            );
        },
      ),
    );
  }
}
