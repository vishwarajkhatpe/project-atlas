import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/profile_sheet.dart';
import 'trip_details_screen.dart';
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
import '../../../core/widgets/atlas_snackbar.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

class TripsDashboardScreen extends ConsumerStatefulWidget {
  const TripsDashboardScreen({super.key});

  @override
  ConsumerState<TripsDashboardScreen> createState() => _TripsDashboardScreenState();
}

class _TripsDashboardScreenState extends ConsumerState<TripsDashboardScreen> {
  RealtimeChannel? _membersChannel;
  RealtimeChannel? _invitesChannel;

  @override
  void initState() {
    super.initState();
    _setupChannels(Supabase.instance.client.auth.currentUser);
  }

  void _setupChannels(User? user) {
    _cleanupChannels();
    
    final userId = user?.id;
    final email = user?.email;
    
    if (userId != null) {
      _membersChannel = Supabase.instance.client.channel('dashboard_members').onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'trip_members',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          if (mounted) {
            ref.invalidate(userTripsProvider);
          }
        },
      )..subscribe();
    }

    if (email != null) {
      _invitesChannel = Supabase.instance.client.channel('dashboard_invites').onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'trip_invitations',
        callback: (payload) {
          if (mounted) {
            ref.invalidate(myInvitationsProvider);
          }
        },
      )..subscribe();
    }
  }

  void _cleanupChannels() {
    if (_membersChannel != null) {
      Supabase.instance.client.removeChannel(_membersChannel!);
      _membersChannel = null;
    }
    if (_invitesChannel != null) {
      Supabase.instance.client.removeChannel(_invitesChannel!);
      _invitesChannel = null;
    }
  }

  @override
  void dispose() {
    _cleanupChannels();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    ref.listen<User?>(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _setupChannels(next);
      }
    });
    
    ref.listen<AsyncValue<void>>(
      memberControllerProvider,
      (_, state) {
        if (!state.isLoading && state.hasError) {
          String errorText = state.error.toString();
          if (errorText.startsWith('Exception: ')) {
            errorText = errorText.substring(11);
          }
          AtlasSnackbar.error(context, errorText);
        }
      },
    );

    final tripsAsync = ref.watch(userTripsProvider);
    final currentUser = ref.watch(currentUserProvider);

    final userName = currentUser?.userMetadata?['full_name'] as String? ?? 'Explorer';

    final hasTrips = tripsAsync.value?.isNotEmpty == true;

    return Scaffold(
      floatingActionButton: hasTrips 
        ? OpenContainer(
            transitionType: ContainerTransitionType.fade,
            openBuilder: (context, _) => const CreateTripSheet(isFullScreen: true),
            closedElevation: 0,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            closedColor: AppColors.primary,
            closedBuilder: (context, openContainer) => FloatingActionButton.extended(
              onPressed: openContainer,
              elevation: 0,
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
              label: Text('New Trip', style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          )
        : null,
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
            edgeOffset: MediaQuery.paddingOf(context).top,
            onRefresh: () async {
              ref.invalidate(userTripsProvider);
              ref.invalidate(myInvitationsProvider);
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Clean Header
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (userName == 'Explorer')
                              Text(
                                '${_getGreeting()}!',
                                style: AppTextStyles.pageTitle,
                              )
                            else ...[
                              Text(
                                '${_getGreeting()},',
                                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                userName.split(' ').first,
                                style: AppTextStyles.pageTitle,
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ProfileSheet.show(context);
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
                  error: (error, stackTrace) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('Error loading invites: $error', style: TextStyle(color: Colors.red)),
                    ),
                  ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                            child: Column(
                              children: List.generate(invites.length, (index) {
                                final invite = invites[index];
                                final trip = invite['trips'];
                                return Padding(
                                  key: ValueKey(invite['id']),
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: _buildMyInviteCard(context, ref, invite, trip),
                                ).animate(delay: (index * 150).ms)
                                 .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                                 .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutQuart);
                              }),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            
            if (hasTrips)
              // Trips List Section Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
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
                    hasScrollBody: false,
                    child: Transform.translate(
                      offset: const Offset(0, -50), // Optically center on the full screen
                      child: AtlasEmptyState(
                        icon: LucideIcons.map,
                        title: 'Ready to explore?',
                        subtitle: 'Create your first adventure to get started.',
                        primaryLabel: 'Plan a Trip',
                        onPrimary: _showCreateTripSheet,
                      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                    ),
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
                        
                        final destination = trip['description']?.toString() ?? '';
                        final imgQuery = destination.isNotEmpty ? Uri.encodeComponent(destination) : 'travel';
                        final lockId = destination.isNotEmpty ? (destination.codeUnits.fold<int>(0, (p, c) => p + c) % 1000 + 1) : 1;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                          child: OpenContainer(
                            transitionType: ContainerTransitionType.fade,
                            closedElevation: 0,
                            openElevation: 0,
                            closedColor: Colors.transparent,
                            openColor: Colors.transparent,
                            middleColor: Colors.transparent,
                            closedShape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
                            ),
                            openBuilder: (context, _) => TripDetailsScreen(tripId: trip['id']),
                            closedBuilder: (context, openContainer) => AtlasCard(
                              padding: EdgeInsets.zero,
                              onTap: openContainer,
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
                                        Image.network(
                                          'https://loremflickr.com/800/600/$imgQuery,landscape/all?lock=$lockId',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: AppColors.primaryLight,
                                            child: const Center(
                                              child: Icon(LucideIcons.map, color: AppColors.primary, size: 36),
                                            ),
                                          ),
                                        ),
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
                                                  try {
                                                    await ref.read(tripControllerProvider.notifier).deleteTrip(trip['id']);
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
                                              } else if (value == 'edit') {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => CreateTripSheet(initialTrip: trip),
                                                );
                                              } else if (value == 'invite') {
                                                context.push('/trip/${trip['id']}');
                                                // Ideally we'd navigate directly to the members tab, but for now 
                                                // navigating to the trip details is the best path.
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      if (trip['description'] != null && (trip['description'] as String).isNotEmpty) ...[
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
                        ),
                      ).animate().fadeIn(
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(milliseconds: index * 80),
                        ).slideY(
                            begin: 0.1,
                            end: 0.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
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

  Widget _buildMyInviteCard(BuildContext context, WidgetRef ref, Map<String, dynamic> invite, Map<String, dynamic>? trip) {
    return AtlasCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trip?['title'] ?? 'Unnamed Trip',
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
          const SizedBox(height: AppSpacing.md),
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
                      invite['trip_id'],
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
