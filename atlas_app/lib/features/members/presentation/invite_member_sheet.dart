import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter/services.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_button.dart';
import '../../../core/widgets/atlas_text_field.dart';
import '../../../core/widgets/atlas_snackbar.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

import 'member_controller.dart';

class InviteMemberSheet extends ConsumerStatefulWidget {
  final String tripId;
  const InviteMemberSheet({super.key, required this.tripId});

  @override
  ConsumerState<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends ConsumerState<InviteMemberSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'member';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _invite() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(memberControllerProvider.notifier).inviteMember(
        widget.tripId,
        _emailController.text.trim(),
        _selectedRole,
      );
      if (mounted) {
        AtlasSnackbar.success(context, 'Invitation sent successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AtlasSnackbar.error(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(memberControllerProvider).isLoading;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_emailController.text.isNotEmpty) {
          final shouldPop = await AtlasConfirmDialog.show(
            context: context,
            title: 'Discard Invitation?',
            content: 'You have entered an email. Are you sure you want to discard it?',
            confirmText: 'Discard',
            isDestructive: true,
          );
          if (shouldPop == true && context.mounted) {
            context.pop();
          }
        } else {
          context.pop();
        }
      },
      child: Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.brd(context),
                      borderRadius: AppRadii.pillRadius,
                    ),
                  ),
                ),
                Text(
                  'Invite People',
                  style: AppTextStyles.pageTitleOf(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Share this trip with your friends.',
                  style: AppTextStyles.secondaryOf(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AtlasTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'friend@example.com',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => 
                    value == null || !value.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(LucideIcons.shield, size: 20, color: AppColors.txtMuted(context)),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'planner',
                      child: Text('Planner', style: AppTextStyles.bodyOf(context)),
                    ),
                    DropdownMenuItem(
                      value: 'member',
                      child: Text('Member', style: AppTextStyles.bodyOf(context)),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                AtlasButton(
                  label: 'Send Invitation',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _invite,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Note: The UI plan mentioned "Copy/share invite link UI"
                // This is a placeholder for future backend implementation
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final link = 'atlas://join?tripId=${widget.tripId}';
                      await Clipboard.setData(ClipboardData(text: link));
                      if (context.mounted) {
                        AtlasSnackbar.success(context, 'Invite link copied to clipboard!');
                      }
                    },
                    icon: const Icon(LucideIcons.link, size: 16),
                    label: const Text('Copy Invite Link'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryAccent(context),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
