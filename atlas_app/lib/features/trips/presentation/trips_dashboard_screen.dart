import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/presentation/auth_controller.dart';
import 'trip_controller.dart';
import 'create_trip_sheet.dart';
import '../../members/presentation/member_controller.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_button.dart';
import '../../../core/widgets/atlas_avatar.dart';
import '../../../core/widgets/atlas_section_header.dart';
import '../../../core/widgets/atlas_empty_state.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

class TripsDashboardScreen extends ConsumerStatefulWidget {
  const TripsDashboardScreen({super.key});

  @override
  ConsumerState<TripsDashboardScreen> createState() => _TripsDashboardScreenState();
}

class _TripsDashboardScreenState extends ConsumerState<TripsDashboardScreen> {
  void _showCreateTripSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTripSheet(),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // Generate a mesh-like gradient
  Widget _buildMeshGradient(String title) {
    final hash = title.hashCode.abs();
    final hue1 = (hash % 360).toDouble();
    final hue2 = (hue1 + 40) % 360;
    final hue3 = (hue1 + 120) % 360;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue1, 0.7, 0.5).toColor(),
            HSLColor.fromAHSL(1, hue2, 0.8, 0.4).toColor(),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HSLColor.fromAHSL(0.6, hue3, 0.8, 0.6).toColor(),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HSLColor.fromAHSL(0.5, hue1, 0.9, 0.7).toColor(),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(userTripsProvider);
    final currentUser = ref.watch(currentUserProvider);

    final userName = currentUser?.userMetadata?['full_name'] as String? ?? 'Explorer';

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTripSheet,
        elevation: 0,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
        label: Text('New Trip', style: AppTextStyles.button.copyWith(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userTripsProvider);
          ref.invalidate(myInvitationsProvider);
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Clean Header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              userName.split(' ').first,
                              style: AppTextStyles.pageTitle,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to profile
                        },
                        child: AtlasAvatar.medium(name: userName),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Invitations (Horizontal Carousel)
            Consumer(
              builder: (context, ref, child) {
                final myInvitesAsync = ref.watch(myInvitationsProvider);
                return myInvitesAsync.when(
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (error, stackTrace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (invites) {
                    if (invites.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                            child: AtlasSectionHeader(title: 'PENDING INVITATIONS'),
                          ),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              itemCount: invites.length,
                              itemBuilder: (context, index) {
                                final invite = invites[index];
                                final trip = invite['trips'];
                                return Padding(
                                  key: ValueKey(invite['id']),
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                  child: SizedBox(
                                    width: 280,
                                    child: _buildMyInviteCard(context, ref, invite, trip),
                                  ),
                                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            
            // Trips List Section Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: AtlasSectionHeader(title: 'YOUR TRIPS'),
              ),
            ),

            // Trips
            tripsAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => SliverToBoxAdapter(child: const AtlasSkeletonList()),
              error: (err, _) => SliverFillRemaining(
                child: AtlasErrorState(
                  title: 'Couldn\'t load trips',
                  subtitle: err.toString(),
                  onRetry: () => ref.invalidate(userTripsProvider),
                ),
              ),
              data: (trips) {
                if (trips.isEmpty) {
                  return SliverFillRemaining(
                    child: AtlasEmptyState(
                      icon: LucideIcons.map,
                      title: 'Ready to explore?',
                      subtitle: 'Create your first adventure to get started.',
                      primaryLabel: 'Plan a Trip',
                      onPrimary: _showCreateTripSheet,
                    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trip = trips[index];
                        final title = trip['title'] ?? 'Unnamed Trip';
                        
                        // Date formatting
                        String dateLabel = 'Dates TBD';
                        int? daysAway;
                        if (trip['start_date'] != null) {
                          final start = DateTime.parse(trip['start_date']);
                          final now = DateTime.now();
                          daysAway = start.difference(now).inDays;
                          final endStr = trip['end_date'] != null
                              ? trip['end_date'].toString().split('T')[0]
                              : 'TBD';
                          dateLabel = '${trip['start_date'].toString().split('T')[0]} → $endStr';
                        }

                        // We can't fetch member count without a separate query per trip, 
                        // so we'll just show a generic label or omit it if not available in the view.
                        // Ideally the backend view 'user_trips' would include a member_count.
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                          child: AtlasCard(
                            padding: EdgeInsets.zero,
                            onTap: () {
                              context.push('/trip/${trip['id']}');
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Rich Gradient Header
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
                                  child: SizedBox(
                                    height: 140,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _buildMeshGradient(title),
                                        // Days-away frosted chip
                                        if (daysAway != null && daysAway >= 0)
                                          Positioned(
                                            top: AppSpacing.md,
                                            right: AppSpacing.md,
                                            child: ClipRRect(
                                              borderRadius: AppRadii.pillRadius,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.3),
                                                borderRadius: AppRadii.pillRadius,
                                                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                              ),
                                              child: Text(
                                                daysAway == 0 ? 'Today!' : '${daysAway}d away',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Trip Details
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: AppTextStyles.sectionTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
                                            shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
                                            color: AppColors.card,
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: const [
                                                    Icon(LucideIcons.pencil, size: 18),
                                                    SizedBox(width: AppSpacing.smd),
                                                    Text('Edit Trip'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'invite',
                                                child: Row(
                                                  children: const [
                                                    Icon(LucideIcons.user_plus, size: 18),
                                                    SizedBox(width: AppSpacing.smd),
                                                    Text('Invite people'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuDivider(),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: const [
                                                    Icon(LucideIcons.trash_2, size: 18, color: AppColors.danger),
                                                    SizedBox(width: AppSpacing.smd),
                                                    Text('Delete Trip', style: TextStyle(color: AppColors.danger)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                final confirm = await AtlasConfirmDialog.show(
                                                  context: context,
                                                  title: 'Delete Trip?',
                                                  content: 'This will permanently delete all data associated with this trip.',
                                                  confirmText: 'Delete',
                                                  isDestructive: true,
                                                );
                                                if (confirm) {
                                                  HapticFeedback.lightImpact();
                                                  ref.read(tripControllerProvider.notifier).deleteTrip(trip['id']);
                                                }
                                              }
                                              // TODO: handle edit and invite
                                            },
                                          ),
                                        ],
                                      ),
                                      if (trip['description'] != null && trip['description'].isNotEmpty) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          trip['description'],
                                          style: AppTextStyles.body,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: AppSpacing.md),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.calendar, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            dateLabel,
                                            style: AppTextStyles.secondary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                      },
                      childCount: trips.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyInviteCard(BuildContext context, WidgetRef ref, Map<String, dynamic> invite, Map<String, dynamic> trip) {
    return AtlasCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.smd),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.map, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['title'] ?? 'Unnamed Trip',
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Invited as ${invite['role']}',
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: AtlasSecondaryButton(
                  label: 'Decline',
                  onPressed: () {
                    ref.read(memberControllerProvider.notifier).declineInvitation(invite['id']);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: AtlasButton(
                  label: 'Accept',
                  onPressed: () {
                    ref.read(memberControllerProvider.notifier).acceptInvitation(
                      invite['id'],
                      trip['id'],
                      invite['role'],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
