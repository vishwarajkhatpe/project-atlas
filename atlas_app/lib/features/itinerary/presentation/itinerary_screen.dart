import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class EventCategoryConfig {
  final IconData icon;
  final Color color;
  final String label;

  const EventCategoryConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}

EventCategoryConfig getEventCategoryConfig(Map<String, dynamic> event) {
  final text = '${event['title']} ${event['location'] ?? ''} ${event['description'] ?? ''}'.toLowerCase();
  if (text.contains('[type:transit]') || text.contains('flight') || text.contains('fly') || text.contains('train') || text.contains('bus') || text.contains('drive') || text.contains('taxi') || text.contains('cab') || text.contains('transit') || text.contains('airport')) {
    return const EventCategoryConfig(icon: LucideIcons.plane, color: AppColors.categoryDestination, label: 'Transit');
  }
  if (text.contains('[type:stay]') || text.contains('hotel') || text.contains('resort') || text.contains('stay') || text.contains('airbnb') || text.contains('check-in') || text.contains('villa') || text.contains('room')) {
    return const EventCategoryConfig(icon: Icons.home, color: AppColors.categoryAccommodation, label: 'Stay');
  }
  if (text.contains('[type:food]') || text.contains('dinner') || text.contains('lunch') || text.contains('breakfast') || text.contains('food') || text.contains('restaurant') || text.contains('cafe') || text.contains('bar') || text.contains('eat') || text.contains('coffee')) {
    return const EventCategoryConfig(icon: LucideIcons.coffee, color: AppColors.categoryDates, label: 'Food & Drink');
  }
  if (text.contains('[type:activity]') || text.contains('tour') || text.contains('visit') || text.contains('hike') || text.contains('beach') || text.contains('museum') || text.contains('park') || text.contains('sightseeing') || text.contains('activity') || text.contains('show') || text.contains('concert')) {
    return const EventCategoryConfig(icon: LucideIcons.activity, color: AppColors.categoryActivity, label: 'Activity');
  }
  return const EventCategoryConfig(icon: LucideIcons.calendar, color: AppColors.primary, label: 'Event');
}

class ItineraryScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ItineraryScreen({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  String? _selectedDateKey; // null means 'All Days'

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventSheet(tripId: widget.tripId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itineraryAsync = ref.watch(tripItineraryProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddEventSheet(context);
            },
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
          onRetry: () => ref.invalidate(tripItineraryProvider(widget.tripId)),
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

          final now = DateTime.now();

          // Chronologically sorted events to find current and next event
          final sortedEvents = List<Map<String, dynamic>>.from(events)
            ..sort((a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));

          String? currentEventId;
          String? nextEventId;

          for (final e in sortedEvents) {
            final start = DateTime.parse(e['start_time']).toLocal();
            final end = DateTime.parse(e['end_time']).toLocal();
            if (start.isBefore(now) && end.isAfter(now)) {
              currentEventId = e['id'].toString();
              break;
            }
          }

          if (currentEventId == null) {
            for (final e in sortedEvents) {
              final start = DateTime.parse(e['start_time']).toLocal();
              if (start.isAfter(now)) {
                nextEventId = e['id'].toString();
                break;
              }
            }
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

          // Filter dates if selected
          final displayDates = (_selectedDateKey != null && groupedEvents.containsKey(_selectedDateKey))
              ? [_selectedDateKey!]
              : sortedDates;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripItineraryProvider(widget.tripId));
            },
            child: CustomScrollView(
              slivers: [
                // 1. Summary Stats Header Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
                    child: AtlasCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBgLight(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.calendar, color: AppColors.primaryAccent(context), size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Schedule Overview',
                                  style: AppTextStyles.captionOf(context).copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${events.length} ${events.length == 1 ? 'event' : 'events'} across ${sortedDates.length} ${sortedDates.length == 1 ? 'day' : 'days'}',
                                  style: AppTextStyles.cardTitleOf(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                ),

                // 2. Horizontal Day Filter Bar
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        _buildDayPill(
                          label: 'All Days (${events.length})',
                          isSelected: _selectedDateKey == null,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedDateKey = null);
                          },
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ...sortedDates.asMap().entries.map((entry) {
                          final dayIndex = entry.key + 1;
                          final dateKey = entry.value;
                          final date = DateTime.parse(dateKey);
                          final isSelected = _selectedDateKey == dateKey;
                          final dayCount = groupedEvents[dateKey]?.length ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: _buildDayPill(
                              label: 'Day $dayIndex • ${DateFormat('MMM d').format(date)} ($dayCount)',
                              isSelected: isSelected,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedDateKey = dateKey);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // 3. Events Timeline List
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, dayIdx) {
                        final dateKey = displayDates[dayIdx];
                        final dayEvents = groupedEvents[dateKey]!;
                        dayEvents.sort((a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
                        final date = DateTime.parse(dateKey);
                        final actualDayNum = sortedDates.indexOf(dateKey) + 1;

                        return Column(
                          key: ValueKey(dateKey),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day Header Badge
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.lg),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: AppRadii.pillRadius,
                                    ),
                                    child: Text(
                                      'DAY $actualDayNum • ${DateFormat('MMM d').format(date).toUpperCase()}',
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

                            // Day Events with Connecting Timeline
                            ...dayEvents.asMap().entries.map((entry) {
                              final eventIndex = entry.key;
                              final event = entry.value;
                              final isLastInDay = eventIndex == dayEvents.length - 1;
                              final start = DateTime.parse(event['start_time']).toLocal();
                              final end = DateTime.parse(event['end_time']).toLocal();
                              final config = getEventCategoryConfig(event);

                              final isCurrent = currentEventId != null && event['id'].toString() == currentEventId;
                              final isNext = nextEventId != null && event['id'].toString() == nextEventId;
                              final isPast = end.isBefore(now);

                              return IntrinsicHeight(
                                key: ValueKey(event['id']),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Time Column
                                    SizedBox(
                                      width: 65,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('h:mm a').format(start),
                                            style: TextStyle(
                                              fontFamily: AppTextStyles.fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.txtPrimary(context),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat('h:mm a').format(end),
                                            style: TextStyle(
                                              fontFamily: AppTextStyles.fontFamily,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.txtMuted(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),

                                    // Continuous Connecting Timeline Node
                                    SizedBox(
                                      width: 24,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: isCurrent
                                                  ? AppColors.success
                                                  : isNext
                                                      ? AppColors.primaryAccent(context)
                                                      : config.color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isCurrent
                                                          ? AppColors.success
                                                          : isNext
                                                              ? AppColors.primary
                                                              : config.color)
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              isCurrent
                                                  ? LucideIcons.radio
                                                  : isNext
                                                      ? LucideIcons.clock
                                                      : config.icon,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (!isLastInDay)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(vertical: 4),
                                                color: (isCurrent
                                                        ? AppColors.success
                                                        : config.color)
                                                    .withValues(alpha: 0.3),
                                              ),
                                            )
                                          else
                                            const SizedBox(height: AppSpacing.lg),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),

                                    // Event Card
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.cardBg(context),
                                            borderRadius: AppRadii.cardRadius,
                                            border: Border.all(color: AppColors.brd(context)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.02),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: AppRadii.cardRadius,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                    color: isCurrent
                                                        ? AppColors.success
                                                        : isNext
                                                            ? AppColors.primaryAccent(context)
                                                            : config.color,
                                                    width: 4,
                                                  ),
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(AppSpacing.md),
                                              child: Builder(
                                                builder: (context) {
                                                  final rawDesc = event['description']?.toString() ?? '';
                                                  final cleanDesc = rawDesc.replaceAll(RegExp(r'\[type:\w+\]\s*'), '').trim();

                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Top Row: Full Title + Action Menu
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              event['title'],
                                                              style: AppTextStyles.cardTitleOf(context),
                                                            ),
                                                          ),
                                                          PopupMenuButton<String>(
                                                            icon: Icon(Icons.more_horiz, size: 20, color: AppColors.txtSecondary(context)),
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
                                                                  ref.read(itineraryControllerProvider.notifier).deleteEvent(widget.tripId, event['id']);
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: AppSpacing.xs),

                                                      // Sub-Row: Category Pill + Status Pill
                                                      Wrap(
                                                        spacing: AppSpacing.xs,
                                                        runSpacing: AppSpacing.xs,
                                                        crossAxisAlignment: WrapCrossAlignment.center,
                                                        children: [
                                                          // Category Pill
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: config.color.withValues(alpha: 0.1),
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Text(
                                                              config.label,
                                                              style: AppTextStyles.caption.copyWith(
                                                                color: config.color,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                          if (isCurrent) ...[
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.success.withValues(alpha: 0.15),
                                                                borderRadius: BorderRadius.circular(10),
                                                                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                                              ),
                                                              child: const Text(
                                                                'NOW',
                                                                style: TextStyle(
                                                                  color: AppColors.success,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ),
                                                          ] else if (isNext) ...[
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.primaryAccent(context).withValues(alpha: 0.15),
                                                                borderRadius: BorderRadius.circular(10),
                                                                border: Border.all(color: AppColors.primaryAccent(context).withValues(alpha: 0.3)),
                                                              ),
                                                              child: Text(
                                                                'UP NEXT',
                                                                style: TextStyle(
                                                                  color: AppColors.primaryAccent(context),
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ),
                                                          ] else if (isPast) ...[
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.inputBg(context),
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: Text(
                                                                'DONE',
                                                                style: TextStyle(
                                                                  color: AppColors.txtMuted(context),
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),

                                                      if (event['location'] != null && event['location'].toString().isNotEmpty) ...[
                                                        const SizedBox(height: AppSpacing.xs),
                                                        Row(
                                                          children: [
                                                            Icon(LucideIcons.map_pin, size: 14, color: AppColors.txtSecondary(context)),
                                                            const SizedBox(width: AppSpacing.xs),
                                                            Expanded(
                                                              child: Text(
                                                                event['location'],
                                                                style: AppTextStyles.secondaryOf(context),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                      if (cleanDesc.isNotEmpty) ...[
                                                        const SizedBox(height: AppSpacing.sm),
                                                        Text(
                                                          cleanDesc,
                                                          style: AppTextStyles.bodyOf(context),
                                                        ),
                                                      ],
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(
                                duration: const Duration(milliseconds: 300),
                                delay: Duration(milliseconds: eventIndex * 60),
                              ).slideX(
                                begin: 0.05,
                                end: 0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            }),
                          ],
                        );
                      },
                      childCount: displayDates.length,
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

  Widget _buildDayPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent(context) : AppColors.inputBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent(context) : AppColors.brd(context),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.txtSecondary(context),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
