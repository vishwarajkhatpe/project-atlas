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
              'Last Updated: August 23, 2026',
              style: AppTextStyles.secondaryOf(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              '1. Data Collection',
              'Project Atlas collects basic account information such as your name and email address when you sign up. We also store trip itineraries, chat messages, and expenses you log within your travel groups.',
            ),
            _buildSection(
              context,
              '2. Data Usage',
              'The data we collect is exclusively used to provide the collaborative features of Project Atlas, including real-time synchronization of itineraries, ledger calculations, and group chat. We do not sell your personal data to third parties.',
            ),
            _buildSection(
              context,
              '3. Security & Storage',
              'Your data is securely stored on Supabase cloud servers. We employ Row-Level Security (RLS) to ensure that your trip data is strictly isolated and only accessible to authorized members of your specific travel group.',
            ),
            _buildSection(
              context,
              '4. Analytics & Crash Reporting',
              'We may collect anonymous crash logs and basic usage telemetry to improve app stability and user experience during the beta testing phase.',
            ),
            _buildSection(
              context,
              '5. Account Deletion',
              'You can request to have your account and all associated data deleted at any time by contacting the developer or using the in-app account management tools (coming soon).',
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
