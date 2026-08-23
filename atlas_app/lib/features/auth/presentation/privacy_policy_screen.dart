import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: AppColors.txtPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.pageTitleOf(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simple & Clear',
              style: AppTextStyles.secondaryOf(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              '🤝 What we collect',
              'We just need your name and email to set up your account. When you plan a trip, we save your itinerary, expenses, and group chat messages so you and your friends can see them.',
            ),
            _buildSection(
              context,
              '🔒 How we keep it safe',
              'Your trips are entirely private to you and your travel buddies. Nobody else can see your travel plans, how much you spend, or what you chat about.',
            ),
            _buildSection(
              context,
              '🚫 No selling data',
              'We built Atlas to help you travel, not to make money off your data. We never sell your personal information or trip details to anyone.',
            ),
            _buildSection(
              context,
              '🗑️ Leaving the app',
              'If you ever want to leave, you can ask us to delete your account, and we will wipe out all your personal data completely.',
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text(
                '© 2026 Project Atlas',
                style: AppTextStyles.captionOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitleOf(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.bodyOf(context).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
