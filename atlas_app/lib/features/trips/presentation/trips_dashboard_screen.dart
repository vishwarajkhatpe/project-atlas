import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(userTripsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.log_out),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTripSheet,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Create Trip'),
      ),
      body: CustomScrollView(
        slivers: [
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
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = trips[index];
                      
                      // Formatted dates
                      final startDate = trip['start_date'] != null
                          ? trip['start_date'].toString().split(' ')[0]
                          : 'TBD';
                      final endDate = trip['end_date'] != null
                          ? trip['end_date'].toString().split(' ')[0]
                          : 'TBD';

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
                              // Image Placeholder
                              Container(
                                height: 160,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE2E8F0), // Border color as placeholder
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.image, size: 48, color: Color(0xFF94A3B8)),
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
                                            trip['title'] ?? 'Unnamed Trip',
                                            style: theme.textTheme.titleLarge,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(LucideIcons.trash_2, size: 20, color: theme.colorScheme.error),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Trip?'),
                                                content: const Text('This action cannot be undone.'),
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
                                      const SizedBox(height: 8),
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
                                        Icon(LucideIcons.calendar, size: 16, color: theme.colorScheme.secondary),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$startDate - $endDate',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w500,
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
