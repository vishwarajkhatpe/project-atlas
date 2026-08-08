import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/widgets/app_card.dart';
import 'itinerary_controller.dart';
import 'add_event_sheet.dart';
import 'package:intl/intl.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tripId;
  const ItineraryScreen({super.key, required this.tripId});

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventSheet(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itineraryAsync = ref.watch(tripItineraryProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showAddEventSheet(context),
          ),
        ],
      ),
      body: itineraryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (events) {
          if (events.isEmpty) {
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
                      child: Icon(LucideIcons.calendar, size: 48, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No events yet.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lock in your plans and build the official schedule.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _showAddEventSheet(context),
                      child: const Text('Add Event'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Group events by day
          final Map<String, List<Map<String, dynamic>>> groupedEvents = {};
          for (var event in events) {
            final startTime = DateTime.parse(event['start_time']).toLocal();
            final dateKey = DateFormat('yyyy-MM-dd').format(startTime);
            if (!groupedEvents.containsKey(dateKey)) {
              groupedEvents[dateKey] = [];
            }
            groupedEvents[dateKey]!.add(event);
          }

          final sortedDates = groupedEvents.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripItineraryProvider(tripId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final dayEvents = groupedEvents[dateKey]!;
                final date = DateTime.parse(dateKey);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              DateFormat('MMM d').format(date),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE').format(date),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...dayEvents.map((event) {
                      final start = DateTime.parse(event['start_time']).toLocal();
                      final end = DateTime.parse(event['end_time']).toLocal();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('h:mm a').format(start),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('h:mm a').format(end),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event['title'],
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(LucideIcons.trash_2, size: 16, color: theme.colorScheme.error),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Event?'),
                                                content: const Text('Are you sure you want to delete this event?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Keep'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      ref.read(itineraryControllerProvider.notifier).deleteEvent(tripId, event['id']);
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    if (event['location'] != null && event['location'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.map_pin, size: 14, color: theme.colorScheme.secondary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              event['location'],
                                              style: theme.textTheme.labelMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (event['description'] != null && event['description'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        event['description'],
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
