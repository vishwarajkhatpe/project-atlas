import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../auth/presentation/auth_controller.dart';
import 'trip_controller.dart';
import '../../../core/widgets/app_card.dart';
import 'create_trip_sheet.dart';
import '../../members/presentation/member_controller.dart';

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
    final theme = Theme.of(context);

    final userName = currentUser?.userMetadata?['full_name'] as String? ?? 'Explorer';
    final firstName = userName.split(' ').first;
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';

    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateTripSheet,
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: const Text('New Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate providers to force a reload
          ref.invalidate(userTripsProvider);
          ref.invalidate(myInvitationsProvider);
          // Small delay to show the spinner
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Glassmorphism App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                firstName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.log_out, size: 20, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Log Out', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (String value) {
                            if (value == 'logout') {
                              ref.read(authControllerProvider.notifier).signOut();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Invitations (Horizontal Carousel)
          Consumer(
            builder: (context, ref, child) {
              final myInvitesAsync = ref.watch(myInvitationsProvider);
              return myInvitesAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (error, stackTrace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (invites) {
                  if (invites.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Text(
                            'Pending Invitations',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: invites.length,
                            itemBuilder: (context, index) {
                              final invite = invites[index];
                              final trip = invite['trips'];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 280,
                                  child: _buildMyInviteCard(context, ref, theme, invite, trip),
                                ),
                              ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          
          // Trips List Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Your Trips',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Trips
          tripsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error loading trips: $err', style: TextStyle(color: theme.colorScheme.error)),
                ),
              ),
            ),
            data: (trips) {
              if (trips.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.map, size: 64, color: theme.colorScheme.secondary),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Ready to explore?',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first adventure to get started.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _showCreateTripSheet,
                            icon: const Icon(LucideIcons.compass),
                            label: const Text('Plan a Trip'),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = trips[index];
                      final title = trip['title'] ?? 'Unnamed Trip';
                      
                      // Created At formatting
                      String createdLabel = '';
                      if (trip['created_at'] != null) {
                        final createdDate = DateTime.parse(trip['created_at']);
                        createdLabel = 'Created ${DateFormat.yMMMd().format(createdDate)}';
                      }
                      
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          onTap: () {
                            context.push('/trip/${trip['id']}');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Rich Gradient Header
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                child: SizedBox(
                                  height: 140,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _buildMeshGradient(title),
                                      // Title overlay
                                      Center(
                                        child: Text(
                                          title.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 56,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white30,
                                            letterSpacing: 12,
                                          ),
                                        ),
                                      ),
                                      // Days-away frosted chip
                                      if (daysAway != null && daysAway >= 0)
                                        Positioned(
                                          top: 16,
                                          right: 16,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(LucideIcons.settings, color: theme.colorScheme.onSurfaceVariant),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(LucideIcons.trash_2, size: 18, color: theme.colorScheme.error),
                                                  const SizedBox(width: 12),
                                                  Text('Delete Trip', style: TextStyle(color: theme.colorScheme.error)),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'delete') {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Trip?'),
                                                  content: const Text('This will permanently delete all data associated with this trip.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => context.pop(),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        ref.read(tripControllerProvider.notifier).deleteTrip(trip['id']);
                                                        context.pop();
                                                      },
                                                      child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    if (trip['description'] != null && trip['description'].isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        trip['description'],
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Icon(LucideIcons.calendar, size: 16, color: theme.colorScheme.secondary),
                                        const SizedBox(width: 8),
                                        Text(
                                          dateLabel,
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (createdLabel.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.clock, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 8),
                                          Text(
                                            createdLabel,
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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

  Widget _buildMyInviteCard(BuildContext context, WidgetRef ref, ThemeData theme, Map<String, dynamic> invite, Map<String, dynamic> trip) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.map, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['title'] ?? 'Unnamed Trip',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invited as ${invite['role']}',
                      style: theme.textTheme.labelMedium,
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
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(memberControllerProvider.notifier).declineInvitation(invite['id']);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(memberControllerProvider.notifier).acceptInvitation(
                      invite['id'],
                      trip['id'],
                      invite['role'],
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
