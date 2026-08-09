import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_empty_state.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

import 'itinerary_controller.dart';
import 'add_event_sheet.dart';

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
    final itineraryAsync = ref.watch(tripItineraryProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showAddEventSheet(context),
          ),
        ],
      ),
      body: itineraryAsync.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const AtlasSkeletonList(),
        error: (err, _) => AtlasErrorState(
          title: 'Couldn\'t load schedule',
          subtitle: err.toString(),
          onRetry: () => ref.invalidate(tripItineraryProvider(tripId)),
        ),
        data: (events) {
          if (events.isEmpty) {
            return AtlasEmptyState(
              icon: LucideIcons.calendar,
              title: 'Nothing planned yet',
              subtitle: 'Start building your trip schedule.',
              primaryLabel: 'Add Event',
              onPrimary: () => _showAddEventSheet(context),
            ).animate().fadeIn();
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final dayEvents = groupedEvents[dateKey]!;
                
                // Sort events within the day by start time
                dayEvents.sort((a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));

                final date = DateTime.parse(dateKey);

                return Column(
                  key: ValueKey(dateKey),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadii.pillRadius,
                            ),
                            child: Text(
                              DateFormat('MMM d').format(date).toUpperCase(),
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.smd),
                          Text(
                            DateFormat('EEEE').format(date),
                            style: AppTextStyles.sectionTitle.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ...dayEvents.map((event) {
                      final start = DateTime.parse(event['start_time']).toLocal();
                      final end = DateTime.parse(event['end_time']).toLocal();
                      return Padding(
                        key: ValueKey(event['id']),
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 65,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('h:mm a').format(start),
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('h:mm a').format(end),
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AtlasCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event['title'],
                                            style: AppTextStyles.cardTitle,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textSecondary),
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: const [
                                                  Icon(LucideIcons.trash_2, size: 18, color: AppColors.danger),
                                                  SizedBox(width: AppSpacing.smd),
                                                  Text('Delete Event', style: TextStyle(color: AppColors.danger)),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'delete') {
                                              final confirm = await AtlasConfirmDialog.show(
                                                context: context,
                                                title: 'Delete Event?',
                                                content: 'Are you sure you want to delete this event?',
                                                confirmText: 'Delete',
                                                isDestructive: true,
                                              );
                                              if (confirm) {
                                                ref.read(itineraryControllerProvider.notifier).deleteEvent(tripId, event['id']);
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    if (event['location'] != null && event['location'].toString().isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.map_pin, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: AppSpacing.xs),
                                          Expanded(
                                            child: Text(
                                              event['location'],
                                              style: AppTextStyles.secondary,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (event['description'] != null && event['description'].toString().isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        event['description'],
                                        style: AppTextStyles.body,
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
