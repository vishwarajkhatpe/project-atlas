import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bouncy_widget.dart';
import '../../../core/theme/app_theme.dart';
import 'proposal_controller.dart';
import '../../auth/presentation/auth_controller.dart';

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
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.id;
    
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

    // Determine icon based on type
    IconData typeIcon;
    Color typeColor;
    switch (proposal['type']) {
      case 'destination':
        typeIcon = LucideIcons.map_pin;
        typeColor = const Color(0xFF8B5CF6); // Purple
        break;
      case 'dates':
        typeIcon = LucideIcons.calendar;
        typeColor = const Color(0xFF10B981); // Emerald
        break;
      case 'accommodation':
        typeIcon = LucideIcons.home;
        typeColor = const Color(0xFFF59E0B); // Amber
        break;
      case 'activity':
        typeIcon = LucideIcons.activity;
        typeColor = const Color(0xFFEC4899); // Pink
        break;
      default:
        typeIcon = LucideIcons.list;
        typeColor = const Color(0xFF64748B); // Slate
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal['title'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proposed by $proposerName',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (proposal['description'] != null && proposal['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              proposal['description'],
              style: theme.textTheme.bodyMedium,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Voting Section
          Row(
            children: [
              _buildVoteButton(
                context: context,
                ref: ref,
                icon: LucideIcons.thumbs_up,
                label: approves.toString(),
                isSelected: myVote == 'approve',
                color: const Color(0xFF10B981),
                voteValue: 'approve',
              ),
              const SizedBox(width: 12),
              _buildVoteButton(
                context: context,
                ref: ref,
                icon: LucideIcons.thumbs_down,
                label: rejects.toString(),
                isSelected: myVote == 'reject',
                color: const Color(0xFFEF4444),
                voteValue: 'reject',
              ),
              const Spacer(),
              if (proposal['status'] == 'approved')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Approved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required String voteValue,
  }) {
    final theme = Theme.of(context);
    
    return BouncyWidget(
      onPressed: () {
        ref.read(proposalControllerProvider.notifier).castVote(
          tripId: tripId,
          proposalId: proposal['id'],
          voteValue: voteValue,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.secondarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
