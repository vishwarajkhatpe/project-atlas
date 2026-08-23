import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/atlas_avatar.dart';
import 'auth_controller.dart';

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.userMetadata?['full_name'] as String? ?? 'Explorer';
    final userEmail = user?.email ?? '';
    final currentThemeMode = ref.watch(themeModeProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
        top: AppSpacing.xl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brd(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Profile Info
          Center(
            child: AtlasAvatar.large(name: userName),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              userName,
              style: AppTextStyles.pageTitleOf(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              userEmail,
              style: AppTextStyles.secondaryOf(context),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Theme Mode Selector
          Text(
            'APPEARANCE',
            style: AppTextStyles.captionOf(context).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.inputBg(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildThemeChip(
                    context,
                    ref,
                    mode: ThemeMode.system,
                    icon: LucideIcons.laptop,
                    label: 'System',
                    isSelected: currentThemeMode == ThemeMode.system,
                  ),
                ),
                Expanded(
                  child: _buildThemeChip(
                    context,
                    ref,
                    mode: ThemeMode.light,
                    icon: LucideIcons.sun,
                    label: 'Light',
                    isSelected: currentThemeMode == ThemeMode.light,
                  ),
                ),
                Expanded(
                  child: _buildThemeChip(
                    context,
                    ref,
                    mode: ThemeMode.dark,
                    icon: LucideIcons.moon,
                    label: 'Dark',
                    isSelected: currentThemeMode == ThemeMode.dark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
          
          // Sign Out Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.buttonRadius,
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: Text(
              'Sign Out',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'v0.1.0-beta',
              style: AppTextStyles.captionOf(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                context.push('/privacy-policy');
              },
              child: Text(
                'Privacy Policy',
                style: AppTextStyles.captionOf(context).copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(
    BuildContext context,
    WidgetRef ref, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBg(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryAccent(context) : AppColors.txtMuted(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.txtPrimary(context) : AppColors.txtMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
