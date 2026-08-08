import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final account = ref.watch(accountStreamProvider).valueOrNull;
    final displayName =
        user?.displayName ?? user?.email.split('@').first ?? 'Guest';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: Center(
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(displayName, style: AppTextStyles.title)),
            const SizedBox(height: 4),
            Center(
              child: Text(
                user?.email ?? '',
                style: AppTextStyles.bodyMuted,
              ),
            ),
            const SizedBox(height: 28),
            _Section(
              title: 'PERSONAL',
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Full name',
                  value: displayName,
                ),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? '—',
                  copyable: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'ACCOUNT',
              children: [
                _InfoRow(
                  icon: Icons.tag,
                  label: 'Account number',
                  value: account?.accountNumber.isNotEmpty == true
                      ? _formatAccountNumber(account!.accountNumber)
                      : '—',
                  copyValue: account?.accountNumber,
                  copyable: true,
                ),
                const _InfoRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Institution',
                  value: 'Al Yaqeen Bank',
                ),
                const _InfoRow(
                  icon: Icons.public,
                  label: 'SWIFT / BIC',
                  value: 'YAQBLYLT',
                  copyable: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAccountNumber(String n) {
    final buffer = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      buffer.write(n[i]);
      if ((i + 1) % 4 == 0 && i != n.length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.6,
            ),
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
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.copyValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool copyable;
  final String? copyValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      trailing: copyable
          ? IconButton(
              tooltip: 'Copy',
              icon: const Icon(
                Icons.copy_outlined,
                color: AppColors.gold,
                size: 18,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyValue ?? value));
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
            )
          : null,
    );
  }
}
