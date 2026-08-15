import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_animated_amount.dart';

import '../../members/presentation/members_screen.dart';
import '../../ledger/presentation/ledger_screen.dart';
import 'trip_controller.dart';
import '../../itinerary/presentation/itinerary_controller.dart';
import '../../consensus/presentation/proposal_controller.dart';
import '../../members/presentation/member_controller.dart';
import '../../ledger/presentation/expense_controller.dart';
import '../../chat/presentation/chat_controller.dart';

class TripOverviewScreen extends ConsumerWidget {
  final String tripId;
  final VoidCallback onNavigateToPlan;
  final VoidCallback onNavigateToDecisions;
  final VoidCallback onNavigateToChat;

  const TripOverviewScreen({
    super.key,
    required this.tripId,
    required this.onNavigateToPlan,
    required this.onNavigateToDecisions,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider);
    final itineraryAsync = ref.watch(tripItineraryProvider(tripId));
    final proposalsAsync = ref.watch(tripProposalsProvider(tripId));
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final messagesAsync = ref.watch(tripMessagesProvider(tripId));

    return Scaffold(
      body: tripsAsync.when(
        loading: () => const AtlasSkeletonList(),
        error: (err, _) => AtlasErrorState(
          title: 'Couldn\'t load trip',
          subtitle: err.toString(),
          onRetry: () => ref.invalidate(userTripsProvider),
        ),
        data: (trips) {
          final trip = trips.firstWhere(
            (t) => t['id'] == tripId,
            orElse: () => <String, dynamic>{},
          );

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

          String dateRange = 'Dates not set';
          if (startDate != null && endDate != null) {
            final startStr = DateFormat('MMM d').format(startDate);
            final endStr = DateFormat('MMM d, yyyy').format(endDate);
            dateRange = '$startStr - $endStr';
          }

          final imageUrl = trip['image_url']?.toString();
          final hasImage = imageUrl != null && imageUrl.isNotEmpty;
          final encodedTitle = Uri.encodeComponent('$title travel destination landscape');
          final seed = trip['id'].hashCode;
          final defaultImage = 'https://image.pollinations.ai/prompt/$encodedTitle?width=800&height=400&nologo=true&seed=$seed';
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userTripsProvider);
              ref.invalidate(tripItineraryProvider(tripId));
              ref.invalidate(tripProposalsProvider(tripId));
              ref.invalidate(tripMembersProvider(tripId));
              ref.invalidate(tripExpensesProvider(tripId));
            },
            child: CustomScrollView(
              slivers: [
                // 1. Enhanced Hero Sliver App Bar
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.primaryAccent(context),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(LucideIcons.users, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MembersScreen(tripId: tripId)),
                        );
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.only(left: 46.0, bottom: description.isNotEmpty ? 72.0 : 44.0),
                    title: Text(
                      title,
                      style: AppTextStyles.pageTitle.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2)),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: hasImage ? imageUrl : defaultImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) => CachedNetworkImage(
                            imageUrl: defaultImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black38,
                                Colors.transparent,
                                Colors.black87,
                              ],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                        if (description.isNotEmpty)
                          Positioned(
                            bottom: 50,
                            left: 46,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.map_pin, size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Positioned(
                          bottom: 16, // Pushed down to sit below the title and destination
                          left: 46, // Matches title padding
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: AppRadii.pillRadius,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.calendar, size: 12, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  dateRange,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3. 4-Metric Summary Grid
                        Text('Trip Overview', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppSpacing.sm),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.5,
                          children: [
                             // Metric 1: Total Cost
                            expensesAsync.when(
                              data: (expenses) {
                                final total = expenses.fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());
                                return _buildMetricCard(
                                  context,
                                  icon: LucideIcons.indian_rupee,
                                  iconColor: AppColors.danger,
                                  bgColor: AppColors.danger.withValues(alpha: 0.15),
                                  title: 'Total Spent',
                                  customValue: AtlasAnimatedAmount(
                                    value: total,
                                    style: AppTextStyles.cardTitleOf(context).copyWith(fontSize: 16),
                                    duration: const Duration(milliseconds: 2200),
                                  ),
                                  subtitle: '${expenses.length} entries',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => LedgerScreen(tripId: tripId)),
                                  ),
                                );
                              },
                              loading: () => const AtlasLoadingSkeleton.card(),
                              error: (err, _) => const SizedBox.shrink(),
                            ),

                            // Metric 2: Events Planned
                            itineraryAsync.when(
                              data: (events) => _buildMetricCard(
                                context,
                                icon: LucideIcons.calendar,
                                iconColor: AppColors.primaryAccent(context),
                                bgColor: AppColors.primaryAccent(context).withValues(alpha: 0.15),
                                title: 'Scheduled',
                                value: '${events.length} Events',
                                subtitle: 'Tap to view',
                                onTap: onNavigateToPlan,
                              ),
                              loading: () => const AtlasLoadingSkeleton.card(),
                              error: (err, _) => const SizedBox.shrink(),
                            ),

                            // Metric 3: Open Votes
                            proposalsAsync.when(
                              data: (proposals) {
                                final openCount = proposals.where((p) => p['status'] == 'pending').length;
                                return _buildMetricCard(
                                  context,
                                  icon: LucideIcons.vote,
                                  iconColor: AppColors.violet,
                                  bgColor: AppColors.violet.withValues(alpha: 0.15),
                                  title: 'Decisions',
                                  value: '$openCount Open',
                                  subtitle: openCount > 0 ? 'Action required' : 'All caught up',
                                  onTap: onNavigateToDecisions,
                                );
                              },
                              loading: () => const AtlasLoadingSkeleton.card(),
                              error: (err, _) => const SizedBox.shrink(),
                            ),

                            // Metric 4: Group Chat Unread Status
                            messagesAsync.when(
                              data: (messages) {
                                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                                int unreadCount = 0;
                                for (final m in messages) {
                                  if (m['user_id'] != currentUserId) {
                                    unreadCount++;
                                  } else {
                                    break;
                                  }
                                }

                                return _buildMetricCard(
                                  context,
                                  icon: LucideIcons.message_circle,
                                  iconColor: unreadCount > 0 ? AppColors.success : AppColors.primaryAccent(context),
                                  bgColor: unreadCount > 0 ? AppColors.success.withValues(alpha: 0.15) : AppColors.primaryAccent(context).withValues(alpha: 0.15),
                                  title: 'Group Chat',
                                  value: messages.isEmpty
                                      ? 'No Messages'
                                      : (unreadCount > 0 ? '$unreadCount New' : 'All Read'),
                                  subtitle: unreadCount > 0 ? 'Pending messages' : 'Up to date',
                                  onTap: onNavigateToChat,
                                );
                              },
                              loading: () => const AtlasLoadingSkeleton.card(),
                              error: (err, _) => const SizedBox.shrink(),
                            ),
                          ],
                        ).animate().fadeIn().slideY(begin: 0.1),
                        const SizedBox(height: AppSpacing.xl),

                        // 4. Smart Up Next Activity Card
                        Text('Up Next', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppSpacing.sm),
                        itineraryAsync.when(
                          data: (events) {
                            if (events.isEmpty) {
                              return AtlasCard(
                                onTap: onNavigateToPlan,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputBackground,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(LucideIcons.calendar_plus, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Nothing scheduled yet', style: AppTextStyles.cardTitle),
                                          const SizedBox(height: 2),
                                          Text('Tap to add your first trip activity', style: AppTextStyles.secondary),
                                        ],
                                      ),
                                    ),
                                    const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                                  ],
                                ),
                              ).animate().fadeIn();
                            }

                            final sorted = List.from(events)
                              ..sort((a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
                            
                            final now = DateTime.now();
                            final upcoming = sorted.firstWhere(
                              (e) => DateTime.parse(e['end_time']).toLocal().isAfter(now),
                              orElse: () => sorted.first,
                            );

                            final startTime = DateTime.parse(upcoming['start_time']).toLocal();
                            final isNow = startTime.isBefore(now) && DateTime.parse(upcoming['end_time']).toLocal().isAfter(now);

                            return AtlasCard(
                              onTap: onNavigateToPlan,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: isNow ? AppColors.success.withValues(alpha: 0.15) : AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isNow ? LucideIcons.radio : LucideIcons.clock,
                                      color: isNow ? AppColors.success : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                upcoming['title'],
                                                style: AppTextStyles.cardTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isNow ? AppColors.success.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isNow ? 'HAPPENING NOW' : 'UP NEXT',
                                                style: TextStyle(
                                                  color: isNow ? AppColors.success : AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('EEEE, MMM d • h:mm a').format(startTime),
                                          style: AppTextStyles.secondary,
                                        ),
                                        if (upcoming['location'] != null && upcoming['location'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.map_pin, size: 12, color: AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  upcoming['location'],
                                                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                                ],
                              ),
                            ).animate().fadeIn();
                          },
                          loading: () => const AtlasLoadingSkeleton.card(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 5. Needs Your Vote Snapshot Card
                        Text('Group Decisions', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppSpacing.sm),
                        proposalsAsync.when(
                          data: (proposals) {
                            final openProposals = proposals.where((p) => p['status'] == 'pending').toList();
                            if (openProposals.isEmpty) {
                              return AtlasCard(
                                onTap: onNavigateToDecisions,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.check_circle_outline, color: AppColors.success),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('All caught up!', style: AppTextStyles.cardTitle),
                                          const SizedBox(height: 2),
                                          Text('No pending proposals to vote on', style: AppTextStyles.secondary),
                                        ],
                                      ),
                                    ),
                                    const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                                  ],
                                ),
                              ).animate().fadeIn();
                            }

                            final topProposal = openProposals.first;
                            return AtlasCard(
                              onTap: onNavigateToDecisions,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.violetLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(LucideIcons.vote, color: AppColors.violet),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topProposal['title'] ?? 'Open Proposal',
                                          style: AppTextStyles.cardTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${openProposals.length} open proposal${openProposals.length == 1 ? '' : 's'} awaiting group votes',
                                          style: AppTextStyles.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.violet,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Vote',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn();
                          },
                          loading: () => const AtlasLoadingSkeleton.card(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 6. Group Chat Snapshot Card
                        Text('Latest Group Chat', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppSpacing.sm),
                        messagesAsync.when(
                          data: (messages) {
                            if (messages.isEmpty) {
                              return AtlasCard(
                                onTap: onNavigateToChat,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(LucideIcons.message_square, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('No chat messages yet', style: AppTextStyles.cardTitle),
                                          const SizedBox(height: 2),
                                          Text('Tap to send the first message to your trip crew', style: AppTextStyles.secondary),
                                        ],
                                      ),
                                    ),
                                    const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                                  ],
                                ),
                              ).animate().fadeIn();
                            }

                            final latest = messages.first;
                            final senderId = latest['user_id'];
                            final currentUserId = Supabase.instance.client.auth.currentUser?.id;

                            int unreadCount = 0;
                            for (final m in messages) {
                              if (m['user_id'] != currentUserId) {
                                unreadCount++;
                              } else {
                                break;
                              }
                            }
                            
                            // Find sender name from members list
                            String senderName = 'Traveler';
                            final membersList = membersAsync.value ?? [];
                            for (final m in membersList) {
                              if (m['user_id'] == senderId || m['id'] == senderId) {
                                senderName = m['profile']?['full_name'] ?? 'Traveler';
                                break;
                              }
                            }

                            final createdAt = DateTime.parse(latest['created_at']).toLocal();
                            final timeStr = DateFormat('h:mm a').format(createdAt);

                            return AtlasCard(
                              onTap: onNavigateToChat,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: unreadCount > 0 ? AppColors.success.withValues(alpha: 0.15) : AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      LucideIcons.message_circle,
                                      color: unreadCount > 0 ? AppColors.success : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                senderName,
                                                style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            if (unreadCount > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.success,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '$unreadCount NEW',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              )
                                            else
                                              Text(
                                                timeStr,
                                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          latest['content'] ?? '',
                                          style: AppTextStyles.secondary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                                ],
                              ),
                            ).animate().fadeIn();
                          },
                          loading: () => const AtlasLoadingSkeleton.card(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 7. Traveler Avatar Strip Card
                        Text('Travelers Crew', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppSpacing.sm),
                        membersAsync.when(
                          data: (members) {
                            return AtlasCard(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => MembersScreen(tripId: tripId)),
                                );
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 36,
                                    child: Row(
                                      children: members.take(4).map((m) {
                                        final name = m['profile']?['full_name'] as String? ?? 'User';
                                        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                                        return Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  if (members.length > 4)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputBackground,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '+${members.length - 4}',
                                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const Spacer(),
                                  Text(
                                    '${members.length} Traveler${members.length == 1 ? '' : 's'}',
                                    style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                                ],
                              ),
                            ).animate().fadeIn();
                          },
                          loading: () => const AtlasLoadingSkeleton.card(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    String? value,
    Widget? customValue,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: AppColors.brd(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                Icon(LucideIcons.arrow_up_right, size: 16, color: AppColors.txtMuted(context)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.captionOf(context)),
                const SizedBox(height: 2),
                if (customValue != null)
                  customValue
                else
                  Text(
                    value ?? '',
                    style: AppTextStyles.cardTitleOf(context).copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
