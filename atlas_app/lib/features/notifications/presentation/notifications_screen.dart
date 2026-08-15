import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_error_state.dart';

import 'notification_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'trip_invite': return LucideIcons.user_plus;
      case 'new_proposal': return LucideIcons.file_text;
      case 'new_vote': return LucideIcons.thumbs_up;
      case 'proposal_finalized': return LucideIcons.circle_check;
      case 'new_event': return LucideIcons.calendar;
      case 'new_expense': return LucideIcons.dollar_sign;
      case 'new_message': return LucideIcons.message_square;
      default: return LucideIcons.bell;
    }
  }

  Color _getColorForType(String type, BuildContext context) {
    switch (type) {
      case 'new_expense': return AppColors.categoryAccommodation;
      case 'new_event': return AppColors.categoryDates;
      case 'new_proposal':
      case 'new_vote':
      case 'proposal_finalized':
        return AppColors.violet;
      default: return AppColors.primaryAccent(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.check_check),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationControllerProvider).markAllAsRead();
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const AtlasSkeletonList(),
        error: (err, _) => AtlasErrorState(
          title: 'Failed to load notifications',
          subtitle: err.toString(),
          onRetry: () => ref.invalidate(notificationsStreamProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bell_off, size: 64, color: AppColors.txtMuted(context)),
                  const SizedBox(height: AppSpacing.md),
                  Text('No notifications yet', style: AppTextStyles.sectionTitleOf(context)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = notif['is_read'] as bool? ?? false;
              final type = notif['type'] as String? ?? '';
              final title = notif['title'] as String? ?? 'Notification';
              final body = notif['body'] as String? ?? '';
              final createdAt = notif['created_at'] != null 
                  ? DateTime.parse(notif['created_at']) 
                  : DateTime.now();

              return Dismissible(
                key: Key(notif['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  child: const Icon(LucideIcons.trash_2, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(notificationControllerProvider).deleteNotification(notif['id']);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      // Delete notification as requested
                      await ref.read(notificationControllerProvider).deleteNotification(notif['id']);
                      // Route to the trip
                      if (context.mounted && notif['trip_id'] != null) {
                        context.push('/trip/${notif['trip_id']}');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isRead 
                            ? AppColors.cardBg(context)
                            : AppColors.primaryAccent(context).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRead 
                              ? AppColors.brd(context)
                              : AppColors.primaryAccent(context).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: _getColorForType(type, context).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForType(type),
                              color: _getColorForType(type, context),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: AppTextStyles.cardTitleOf(context).copyWith(
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timeago.format(createdAt),
                                      style: AppTextStyles.captionOf(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  body,
                                  style: AppTextStyles.secondaryOf(context).copyWith(
                                    color: isRead ? AppColors.txtMuted(context) : AppColors.txtSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
