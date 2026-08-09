import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import 'trip_controller.dart';
import '../../itinerary/presentation/itinerary_controller.dart';
import '../../consensus/presentation/proposal_controller.dart';
import '../../members/presentation/member_controller.dart';

class TripOverviewScreen extends ConsumerWidget {
  final String tripId;
  final VoidCallback onNavigateToPlan;
  final VoidCallback onNavigateToDecisions;

  const TripOverviewScreen({
    super.key,
    required this.tripId,
    required this.onNavigateToPlan,
    required this.onNavigateToDecisions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We'll need the trip details to show the title and dates
    final tripsAsync = ref.watch(userTripsProvider);
    final itineraryAsync = ref.watch(tripItineraryProvider(tripId));
    final proposalsAsync = ref.watch(tripProposalsProvider(tripId));
    final membersAsync = ref.watch(tripMembersProvider(tripId));

    return Scaffold(
      body: tripsAsync.when(
        loading: () => const AtlasSkeletonList(),
        error: (err, _) => AtlasErrorState(
          title: 'Couldn\'t load trip',
          subtitle: err.toString(),
          onRetry: () => ref.invalidate(userTripsProvider),
        ),
        data: (trips) {
          final trip = trips.firstWhere((t) => t['id'] == tripId,
              orElse: () => <String, dynamic>{});

          if (trip.isEmpty) {
            return const Center(child: Text('Trip not found'));
          }

          final title = trip['title'] as String? ?? 'Trip';
          final description = trip['description'] as String? ?? '';
          final startDate = trip['start_date'] != null
              ? DateTime.parse(trip['start_date'])
              : null;
          final endDate = trip['end_date'] != null
              ? DateTime.parse(trip['end_date'])
              : null;

          String dateRange = 'Dates TBD';
          if (startDate != null && endDate != null) {
            final startStr = DateFormat('MMM d').format(startDate);
            final endStr = DateFormat('MMM d').format(endDate);
            dateRange = '$startStr - $endStr';
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    title,
                    style: AppTextStyles.pageTitle.copyWith(
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder gradient since we don't have cover images yet
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                          ),
                        ),
                      ),
                      // Gradient overlay for text readability
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(dateRange, style: AppTextStyles.secondary),
                          const SizedBox(width: AppSpacing.md),
                          membersAsync.when(
                            data: (members) => Row(
                              children: [
                                const Icon(LucideIcons.users,
                                    size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: AppSpacing.sm),
                                Text('${members.length} travelers',
                                    style: AppTextStyles.secondary),
                              ],
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (err, stack) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(description, style: AppTextStyles.body),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Up Next', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: AppSpacing.md),
                      itineraryAsync.when(
                        data: (events) {
                          if (events.isEmpty) {
                            return AtlasCard(
                              onTap: onNavigateToPlan,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(LucideIcons.calendar_plus,
                                        color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Nothing scheduled yet',
                                            style: AppTextStyles.cardTitle),
                                        Text('Tap to add your first event',
                                            style: AppTextStyles.secondary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          // Sort and find next event (simplification: just take the first one)
                          final sortedEvents = List.from(events)
                            ..sort((a, b) => DateTime.parse(a['start_time'])
                                .compareTo(DateTime.parse(b['start_time'])));
                          final nextEvent = sortedEvents.first;
                          final startTime =
                              DateTime.parse(nextEvent['start_time']).toLocal();

                          return AtlasCard(
                            onTap: onNavigateToPlan,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.calendar_clock,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(nextEvent['title'],
                                          style: AppTextStyles.cardTitle),
                                      Text(
                                          DateFormat('MMM d, h:mm a')
                                              .format(startTime),
                                          style: AppTextStyles.secondary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const AtlasLoadingSkeleton.card(),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Needs your vote',
                          style: AppTextStyles.sectionTitle),
                      const SizedBox(height: AppSpacing.md),
                      proposalsAsync.when(
                        data: (proposals) {
                          final openProposals = proposals
                              .where((p) => p['status'] == 'pending')
                              .toList();
                          if (openProposals.isEmpty) {
                            return AtlasCard(
                              onTap: onNavigateToDecisions,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.check_circle_outline,
                                        color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('All caught up',
                                            style: AppTextStyles.cardTitle),
                                        Text('No pending decisions',
                                            style: AppTextStyles.secondary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return AtlasCard(
                            onTap: onNavigateToDecisions,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.violetLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.vote,
                                      color: AppColors.violet),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${openProposals.length} open proposal${openProposals.length == 1 ? '' : 's'}',
                                          style: AppTextStyles.cardTitle),
                                      Text('Tap to cast your vote',
                                          style: AppTextStyles.secondary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const AtlasLoadingSkeleton.card(),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
