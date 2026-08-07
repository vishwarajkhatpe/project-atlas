import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/presentation/auth_controller.dart';
import 'trip_controller.dart';
import '../../../core/widgets/app_card.dart';
import 'create_trip_sheet.dart';

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
            icon: const Icon(LucideIcons.logOut),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTripSheet,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Create Trip'),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading trips: $err', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
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
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userTripsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: trips.length,
              itemBuilder: (context, index) {
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
                      // Navigate to trip details
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
                              Text(
                                trip['name'] ?? 'Unnamed Trip',
                                style: theme.textTheme.titleLarge,
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
            ),
          );
        },
      ),
    );
  }
}
