import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_avatar.dart';
import '../../../core/widgets/atlas_chip.dart';
import '../../../core/widgets/atlas_section_header.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_snackbar.dart';

import 'member_controller.dart';
import 'invite_member_sheet.dart';

class MembersScreen extends ConsumerWidget {
  final String tripId;
  const MembersScreen({super.key, required this.tripId});

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteMemberSheet(tripId: tripId),
    );
  }

  void _shareInviteLink() {
    HapticFeedback.lightImpact();
    final link = 'atlas://join?tripId=$tripId';
    final text = 'Join our trip on Atlas! Tap this link to join automatically: $link';
    
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final invitesAsync = ref.watch(tripInvitationsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share_2),
            tooltip: 'Share Invite Link',
            onPressed: _shareInviteLink,
          ),
          IconButton(
            icon: const Icon(LucideIcons.user_plus),
            onPressed: () => _showInviteSheet(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Pending Invitations
          invitesAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (error, stackTrace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (invites) {
              if (invites.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final invite = invites[index];
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AtlasSectionHeader(title: 'PENDING INVITATIONS'),
                            _buildInviteCard(context, ref, invite),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                      }
                      return _buildInviteCard(context, ref, invite).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                    },
                    childCount: invites.length,
                  ),
                ),
              );
            },
          ),
          
          // Current Members
          membersAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const SliverToBoxAdapter(child: AtlasSkeletonList()),
            error: (err, _) => SliverFillRemaining(
              child: AtlasErrorState(
                title: 'Couldn\'t load members',
                subtitle: err.toString(),
                onRetry: () => ref.invalidate(tripMembersProvider(tripId)),
              ),
            ),
            data: (members) {
              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final member = members[index];
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AtlasSectionHeader(
                              title: '${members.length} MEMBER${members.length == 1 ? '' : 'S'}',
                            ),
                            _buildMemberCard(context, ref, member),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                      }
                      return _buildMemberCard(context, ref, member).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                    },
                    childCount: members.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, WidgetRef ref, Map<String, dynamic> invite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AtlasCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.mail, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invite['email'] ?? 'Unknown',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const AtlasChip.pending(),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Invited as ${invite['role']}',
                        style: AppTextStyles.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 20),
              color: AppColors.danger,
              onPressed: () async {
                final confirm = await AtlasConfirmDialog.show(
                  context: context,
                  title: 'Cancel Invitation?',
                  content: 'Are you sure you want to cancel this invitation?',
                  confirmText: 'Cancel Invite',
                  isDestructive: true,
                );
                if (confirm) {
                  try {
                    await ref.read(memberControllerProvider.notifier).cancelInvitation(invite['id'], tripId);
                  } catch (e) {
                    if (context.mounted) {
                      AtlasSnackbar.error(context, 'Failed to cancel: $e');
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, WidgetRef ref, Map<String, dynamic> member) {
    final user = member['users'];
    final name = user != null ? (user['full_name'] ?? 'Unknown User') : 'Unknown User';
    final role = member['role'] ?? 'member';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AtlasCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            AtlasAvatar.medium(name: name),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.cardTitle,
                  ),
                  if (user != null && user['email'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user['email'],
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ],
              ),
            ),
            if (role == 'owner')
              const AtlasChip.owner()
            else ...[
              const AtlasChip.member(),
              const SizedBox(width: AppSpacing.xs),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: const [
                        Icon(LucideIcons.user_minus, size: 18, color: AppColors.danger),
                        SizedBox(width: AppSpacing.smd),
                        Text('Remove from Trip', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'remove') {
                    final confirm = await AtlasConfirmDialog.show(
                      context: context,
                      title: 'Remove Member?',
                      content: 'Are you sure you want to remove this member from the trip?',
                      confirmText: 'Remove',
                      isDestructive: true,
                    );
                    if (confirm) {
                      try {
                        final targetUserId = member['user_id'] as String;
                        final targetEmail = user?['email'] as String?;
                        await ref.read(memberControllerProvider.notifier).removeMember(tripId, targetUserId, email: targetEmail);
                      } catch (e) {
                        if (context.mounted) {
                          String errorText = e.toString();
                          if (errorText.startsWith('Exception: ')) {
                            errorText = errorText.substring(11);
                          }
                          AtlasSnackbar.error(context, errorText);
                        }
                      }
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
