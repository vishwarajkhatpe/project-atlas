import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  // Generate a consistent gradient from a trip title
  List<Color> _tripGradient(String title) {
    final hash = title.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return [
      HSLColor.fromAHSL(1, hue, 0.6, 0.55).toColor(),
      HSLColor.fromAHSL(1, (hue + 30) % 360, 0.7, 0.45).toColor(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(userTripsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    final userName = currentUser?.userMetadata?['full_name'] as String? ?? 'Explorer';
    final firstName = userName.split(' ').first;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTripSheet,
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Trip'),
      ),
      body: CustomScrollView(
        slivers: [
          // Personalized Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $firstName 👋',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plan your next adventure.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.log_out, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0, duration: 500.ms),
            ),
          ),

          // Invitations
          Consumer(
            builder: (context, ref, child) {
              final myInvitesAsync = ref.watch(myInvitationsProvider);
              return myInvitesAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (error, stackTrace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (invites) {
                  if (invites.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final invite = invites[index];
                          final trip = invite['trips'];
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pending Invitations',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildMyInviteCard(context, ref, theme, invite, trip),
                              ],
                            );
                          }
                          return _buildMyInviteCard(context, ref, theme, invite, trip);
                        },
                        childCount: invites.length,
                      ),
                    ),
                  );
                },
              );
            },
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
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.compass, size: 48, color: theme.colorScheme.secondary),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No trips yet.',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first adventure.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _showCreateTripSheet,
                            child: const Text('Create Trip'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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

                      final gradient = _tripGradient(title);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          onTap: () {
                            context.push('/trip/${trip['id']}');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Gradient Header
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                ),
                                child: Stack(
                                  children: [
                                    // Subtle pattern overlay
                                    Positioned(
                                      right: -20,
                                      bottom: -20,
                                      child: Icon(
                                        LucideIcons.compass,
                                        size: 100,
                                        color: Colors.white.withAlpha(25),
                                      ),
                                    ),
                                    // Title initials
                                    Center(
                                      child: Text(
                                        title.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(3).join().toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white24,
                                          letterSpacing: 8,
                                        ),
                                      ),
                                    ),
                                    // Days-away chip
                                    if (daysAway != null && daysAway >= 0)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            daysAway == 0 ? 'Today!' : '${daysAway}d away',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
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
                                            style: theme.textTheme.titleLarge,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(LucideIcons.trash_2, size: 18, color: theme.colorScheme.error.withAlpha(150)),
                                          onPressed: () {
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
                                          },
                                        ),
                                      ],
                                    ),
                                    if (trip['description'] != null && trip['description'].isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        trip['description'],
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(LucideIcons.calendar, size: 14, color: theme.colorScheme.secondary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            dateLabel,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms).slideY(begin: 0.08, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                    },
                    childCount: trips.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyInviteCard(BuildContext context, WidgetRef ref, ThemeData theme, Map<String, dynamic> invite, Map<String, dynamic> trip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: const EdgeInsets.all(16),
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You were invited as ${invite['role']}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(memberControllerProvider.notifier).declineInvitation(invite['id']);
                    },
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(memberControllerProvider.notifier).acceptInvitation(
                        invite['id'],
                        trip['id'],
                        invite['role'],
                      );
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
