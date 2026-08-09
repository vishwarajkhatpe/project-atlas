import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final theme = Theme.of(context);
    final proposalsAsync = ref.watch(tripProposalsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showCreateProposalSheet(context),
          ),
        ],
      ),
      body: proposalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (proposals) {
          if (proposals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.lightbulb, size: 48, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No proposals yet.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Propose dates, destinations, or activities.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _showCreateProposalSheet(context),
                      child: const Text('New Proposal'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripProposalsProvider(tripId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
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

