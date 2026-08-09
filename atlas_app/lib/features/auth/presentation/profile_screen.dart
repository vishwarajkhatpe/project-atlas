import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_avatar.dart';
import '../../../core/widgets/atlas_button.dart';

import 'auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'Atlas User';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Column(
                children: [
                  AtlasAvatar.large(name: fullName),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    fullName,
                    style: AppTextStyles.pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    email,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            _buildSection(
              title: 'Account',
              children: [
                _buildListTile(
                  icon: LucideIcons.bell,
                  title: 'Notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                  },
                ),
                _buildListTile(
                  icon: LucideIcons.palette,
                  title: 'Appearance',
                  trailing: const Text('Light', style: TextStyle(color: AppColors.textSecondary)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                  },
                ),
                _buildListTile(
                  icon: LucideIcons.indian_rupee,
                  title: 'Currency',
                  trailing: const Text('INR (₹)', style: TextStyle(color: AppColors.textSecondary)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                  },
                ),
              ],
            ),
            
            _buildSection(
              title: 'Support',
              children: [
                _buildListTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                  },
                ),
                _buildListTile(
                  icon: LucideIcons.shield,
                  title: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                  },
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AtlasSecondaryButton(
                label: 'Sign Out',
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? null : () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  // The GoRouter redirect in app_router will handle the navigation to /login automatically
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadii.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title, style: AppTextStyles.body),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: AppSpacing.sm),
            ],
            const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
