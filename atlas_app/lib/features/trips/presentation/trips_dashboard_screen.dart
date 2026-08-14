import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

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
  String _selectedFilter = 'all'; // 'all', 'upcoming', 'past'

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
    if (hour >= 5 && hour < 12) return 'Good morning ☀️';
    if (hour >= 12 && hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: hasTrips 
        ? Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showCreateTripSheet();
              },
              elevation: 6,
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.06, duration: 1200.ms, curve: Curves.easeInOut)
            .boxShadow(
              begin: BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 4,
                spreadRadius: 0,
              ),
              end: BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              duration: 1200.ms,
              curve: Curves.easeInOut,
            ),
          )
        : null,
      backgroundColor: AppColors.bg(context),
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
            // 1. Dynamic Greeting & Profile Header
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getGreeting(),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName == 'Explorer' ? 'Ready to explore?' : userName.split(' ').first,
                              style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ProfileSheet.show(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                          ),
                          child: AtlasAvatar.medium(name: userName),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Pending Invitations Section
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
                      child: Text('Error loading invites: $error', style: const TextStyle(color: Colors.red)),
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
            
            // 3. Status Filter Bar & Trips Header
            if (hasTrips)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xs),
                      child: AtlasSectionHeader(title: 'YOUR TRIPS'),
                    ),
                    // Filter Chips (All, Upcoming, Past)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Row(
                        children: [
                          _buildFilterChip('all', '🌴 All Trips'),
                          const SizedBox(width: AppSpacing.xs),
                          _buildFilterChip('upcoming', '🚀 Upcoming'),
                          const SizedBox(width: AppSpacing.xs),
                          _buildFilterChip('past', '📜 Past Adventures'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),

            // 4. Trips List
            tripsAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const SliverToBoxAdapter(child: AtlasSkeletonList()),
              error: (err, _) => SliverFillRemaining(
                child: AtlasErrorState(
                  title: 'Couldn\'t load trips',
                  subtitle: err.toString(),
                  onRetry: () => ref.invalidate(userTripsProvider),
                ),
              ),
              data: (allTrips) {
                final now = DateTime.now();

                // Apply status filter
                final trips = allTrips.where((t) {
                  if (_selectedFilter == 'all') return true;
                  final startDate = t['start_date'] != null ? DateTime.parse(t['start_date']) : null;
                  if (startDate == null) return _selectedFilter == 'upcoming';
                  if (_selectedFilter == 'upcoming') {
                    return startDate.isAfter(now.subtract(const Duration(days: 1)));
                  } else {
                    return startDate.isBefore(now.subtract(const Duration(days: 1)));
                  }
                }).toList();

                if (trips.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Transform.translate(
                      offset: const Offset(0, -30),
                      child: AtlasEmptyState(
                        icon: LucideIcons.map,
                        title: _selectedFilter == 'all' ? 'Ready to explore?' : 'No $_selectedFilter trips',
                        subtitle: 'Create your next adventure to get started.',
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
                          daysAway = start.difference(now).inDays;
                          final startStr = DateFormat('MMM d').format(start);
                          final endStr = trip['end_date'] != null
                              ? DateFormat('MMM d, yyyy').format(DateTime.parse(trip['end_date']))
                              : 'TBD';
                          dateLabel = '$startStr → $endStr';
                        }

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
                                  // Rich Cover Header Image with Gradient & Days Away Badge
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
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent, Colors.black45],
                                              ),
                                            ),
                                          ),
                                          // Days-away pill chip
                                          if (daysAway != null)
                                            Positioned(
                                              top: AppSpacing.md,
                                              right: AppSpacing.md,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                                ),
                                                child: Text(
                                                  daysAway == 0
                                                      ? '⚡ TODAY'
                                                      : (daysAway > 0 ? '🚀 IN ${daysAway}d' : '📜 PAST'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Trip Info & Actions
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
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        if (trip['description'] != null && (trip['description'] as String).isNotEmpty) ...[
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            trip['description'],
                                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: AppSpacing.md),
                                        Row(
                                          children: [
                                            const Icon(LucideIcons.calendar, size: 15, color: AppColors.textSecondary),
                                            const SizedBox(width: AppSpacing.xs),
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
                        ).animate(delay: (index * 60).ms)
                         .fadeIn(duration: 350.ms)
                         .slideY(begin: 0.1, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
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

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent(context) : AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent(context) : AppColors.brd(context),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent(context).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            color: isSelected ? Colors.white : AppColors.txtPrimary(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
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
                decoration: const BoxDecoration(
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
