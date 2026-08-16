import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_chip.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

import 'proposal_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../members/presentation/member_controller.dart';

class ProposalCard extends ConsumerWidget {
  final String tripId;
  final Map<String, dynamic> proposal;

  const ProposalCard({
    super.key,
    required this.tripId,
    required this.proposal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.id;
    final isCreator = proposal['proposed_by'] == currentUserId;
    
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final members = membersAsync.value ?? [];
    final currentMember = members.where((m) => m['user_id'] == currentUserId).firstOrNull;
    final currentRole = currentMember != null ? currentMember['role'] : 'member';
    final isPlannerOrOwner = currentRole == 'planner' || currentRole == 'owner';
    
    final proposer = proposal['users'];
    final proposerName = proposer != null ? (proposer['full_name'] ?? 'Unknown') : 'Unknown';
    
    // Parse votes
    final votes = List<Map<String, dynamic>>.from(proposal['votes'] ?? []);
    int approves = 0;
    int rejects = 0;
    String? myVote;

    for (final vote in votes) {
      if (vote['vote'] == 'approve') approves++;
      if (vote['vote'] == 'reject') rejects++;
      if (vote['user_id'] == currentUserId) {
        myVote = vote['vote'];
      }
    }

    final totalVotes = approves + rejects;

    // Determine icon based on type
    IconData typeIcon;
    Color typeColor;
    switch (proposal['type']) {
      case 'destination':
        typeIcon = LucideIcons.map_pin;
        typeColor = AppColors.categoryDestination;
        break;
      case 'dates':
        typeIcon = LucideIcons.calendar;
        typeColor = AppColors.categoryDates;
        break;
      case 'accommodation':
        typeIcon = Icons.home;
        typeColor = AppColors.categoryAccommodation;
        break;
      case 'activity':
        typeIcon = LucideIcons.activity;
        typeColor = AppColors.categoryActivity;
        break;
      default:
        typeIcon = LucideIcons.list;
        typeColor = AppColors.categoryDefault;
    }

    return AtlasCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.smd),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal['title'],
                      style: AppTextStyles.cardTitleOf(context),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Proposed by $proposerName',
                      style: AppTextStyles.secondaryOf(context),
                    ),
                  ],
                ),
              ),
              if (proposal['status'] == 'approved') ...[
                const SizedBox(width: AppSpacing.sm),
                const AtlasChip.approved(),
              ] else if (proposal['status'] == 'rejected') ...[
                const SizedBox(width: AppSpacing.sm),
                const AtlasChip.rejected(),
              ],
              if (isCreator)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, size: 20, color: AppColors.txtSecondary(context)),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(LucideIcons.trash_2, size: 18, color: AppColors.danger),
                          SizedBox(width: AppSpacing.smd),
                          Text('Delete Proposal', style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await AtlasConfirmDialog.show(
                        context: context,
                        title: 'Delete Proposal?',
                        content: 'Are you sure you want to delete this proposal?',
                        confirmText: 'Delete',
                        isDestructive: true,
                      );
                      if (confirm) {
                        HapticFeedback.lightImpact();
                        ref.read(proposalControllerProvider.notifier).deleteProposal(
                          tripId: tripId,
                          proposalId: proposal['id'],
                        );
                      }
                    }
                  },
                ),
            ],
          ),
          
          if (proposal['description'] != null && proposal['description'].toString().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              proposal['description'],
              style: AppTextStyles.bodyOf(context),
            ),
          ],
          
          const SizedBox(height: AppSpacing.xl),
          
          // Progress bar if votes exist
          if (totalVotes > 0) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadii.pillRadius,
                    child: LinearProgressIndicator(
                      value: approves / totalVotes,
                      backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '$approves of $totalVotes agree',
                  style: AppTextStyles.captionOf(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          
          // Voting Buttons
          if (proposal['status'] == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: _buildVoteButton(
                    context: context,
                    ref: ref,
                    label: 'Agree',
                    isSelected: myVote == 'approve',
                    color: AppColors.success,
                    voteValue: 'approve',
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: _buildVoteButton(
                    context: context,
                    ref: ref,
                    label: 'Not for me',
                    isSelected: myVote == 'reject',
                    color: AppColors.danger,
                    voteValue: 'reject',
                  ),
                ),
              ],
            ),
            if (isPlannerOrOwner) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(proposalControllerProvider.notifier).resolveProposal(tripId, proposal['id'], 'rejected');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg(context),
                          borderRadius: AppRadii.buttonRadius,
                        ),
                        alignment: Alignment.center,
                        child: const Text('Reject Proposal', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.smd),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(proposalControllerProvider.notifier).resolveProposal(tripId, proposal['id'], 'approved');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent(context),
                          borderRadius: AppRadii.buttonRadius,
                        ),
                        alignment: Alignment.center,
                        child: const Text('Finalize', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required bool isSelected,
    required Color color,
    required String voteValue,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(proposalControllerProvider.notifier).castVote(
          tripId: tripId,
          proposalId: proposal['id'],
          voteValue: voteValue,
        );
      },
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColors.inputBg(context),
            borderRadius: AppRadii.buttonRadius,
            border: Border.all(
              color: isSelected ? color : AppColors.brd(context),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(LucideIcons.check, size: 14, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: isSelected ? color : AppColors.txtSecondary(context),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
