import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/atlas_empty_state.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';

import 'proposal_controller.dart';
import 'create_proposal_sheet.dart';
import 'proposal_card.dart';

class ConsensusScreen extends ConsumerWidget {
  final String tripId;
  const ConsensusScreen({super.key, required this.tripId});

  void _showCreateProposalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateProposalSheet(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(tripProposalsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decisions'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showCreateProposalSheet(context),
          ),
        ],
      ),
      body: proposalsAsync.when(
        loading: () => const AtlasSkeletonList(),
        error: (err, _) => AtlasErrorState(
          title: 'Couldn\'t load decisions',
          subtitle: err.toString(),
          onRetry: () => ref.invalidate(tripProposalsProvider(tripId)),
        ),
        data: (proposals) {
          if (proposals.isEmpty) {
            return AtlasEmptyState(
              icon: LucideIcons.lightbulb,
              title: 'No decisions yet',
              subtitle: 'Create a proposal for the group to vote on.',
              primaryLabel: 'New Proposal',
              onPrimary: () => _showCreateProposalSheet(context),
            ).animate().fadeIn();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripProposalsProvider(tripId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: ProposalCard(
                    tripId: tripId,
                    proposal: proposals[index],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
              },
            ),
          );
        },
      ),
    );
  }
}
