import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_avatar.dart';
import '../../../core/widgets/atlas_empty_state.dart';
import '../../../core/widgets/atlas_snackbar.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';

import '../../members/presentation/member_controller.dart';
import '../../members/presentation/members_screen.dart';
import 'chat_controller.dart';
import 'animated_chat_background.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String tripId;

  const ChatScreen({super.key, required this.tripId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();
    ref.read(chatControllerProvider.notifier).sendMessage(
          tripId: widget.tripId,
          content: content,
        );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(chatControllerProvider, (previous, next) {
      if (next.hasError) {
        // Strip out 'Exception: ' if present for a cleaner UI message
        String errorText = next.error.toString();
        if (errorText.startsWith('Exception: ')) {
          errorText = errorText.substring(11);
        }
        AtlasSnackbar.error(context, errorText);
      }
    });

    final messagesState = ref.watch(tripMessagesProvider(widget.tripId));
    final membersState = ref.watch(tripMembersProvider(widget.tripId));
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Create a lookup map for fast user details access
    final membersMap = <String, Map<String, dynamic>>{};
    final membersList = membersState.value;
    if (membersList != null) {
      for (final member in membersList) {
        final user = member['users'];
        if (user != null) {
          membersMap[user['id']] = user;
        }
      }
    }

    final memberCount = membersState.value?.length ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.bg(context).withValues(alpha: 0.75),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Group Chat'),
            if (memberCount > 0)
              Text(
                '$memberCount ${memberCount == 1 ? 'member' : 'members'} in trip',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.users),
            tooltip: 'View Members',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MembersScreen(tripId: widget.tripId)),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedChatBackground(),
          Positioned.fill(
            child: messagesState.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              data: (messages) {
                if (messages.isEmpty) {
                  return AtlasEmptyState(
                    icon: LucideIcons.message_circle,
                    title: 'Start the conversation',
                    subtitle: 'Plan the trip together, share ideas, and more.',
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Start from bottom
                  padding: EdgeInsets.only(
                    left: AppSpacing.md, 
                    right: AppSpacing.md, 
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight + AppSpacing.md,
                    bottom: 120, // Space for input area
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['user_id'] == currentUserId;
                    final sender = membersMap[message['user_id']];
                    final senderName = sender != null ? (sender['full_name'] ?? 'Unknown') : 'Unknown';
                    final timestamp = DateTime.parse(message['created_at']).toLocal();

                    bool showAvatar = true;
                    if (index < messages.length - 1) {
                      final prevMessage = messages[index + 1];
                      if (prevMessage['user_id'] == message['user_id']) {
                        showAvatar = false;
                      }
                    }

                    // Add date separator logic
                    bool showDate = false;
                    if (index == messages.length - 1) {
                      showDate = true;
                    } else {
                      final prevMessageDate = DateTime.parse(messages[index + 1]['created_at']).toLocal();
                      if (timestamp.difference(prevMessageDate).inDays.abs() > 0 || timestamp.day != prevMessageDate.day) {
                        showDate = true;
                      }
                    }

                    return Column(
                      key: ValueKey(message['id']),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.inputBg(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.brd(context).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                DateFormat.yMMMd().format(timestamp),
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.txtSecondary(context),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        _buildMessageBubble(
                          messageId: message['id'].toString(),
                          content: message['content'],
                          isMe: isMe,
                          senderName: senderName,
                          timestamp: timestamp,
                          showAvatar: showAvatar,
                          onLongPress: isMe ? () async {
                            HapticFeedback.mediumImpact();
                            final shouldDelete = await AtlasConfirmDialog.show(
                              context: context,
                              title: 'Delete Message?',
                              content: 'This message will be permanently deleted for everyone in the trip.',
                              confirmText: 'Delete',
                              isDestructive: true,
                            );
                            if (shouldDelete == true) {
                              // Await the deletion to finish on the backend
                              final success = await ref.read(chatControllerProvider.notifier).deleteMessage(message['id']);
                              
                              if (success && context.mounted) {
                                // Invalidate the stream provider so it instantly fetches the updated list
                                ref.invalidate(tripMessagesProvider(widget.tripId));
                              }
                            }
                          } : null,
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                      ],
                    );
                  },
                );
              },
              loading: () => const AtlasSkeletonList(),
              error: (error, stack) => AtlasErrorState(
                title: 'Couldn\'t load messages',
                subtitle: error.toString(),
                onRetry: () => ref.invalidate(tripMessagesProvider(widget.tripId)),
              ),
            ),
          ),
          
          // Chat Input Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.bg(context).withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(top: BorderSide(color: AppColors.brd(context).withValues(alpha: 0.6), width: 1)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      minLines: 1,
                      style: AppTextStyles.bodyOf(context),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBg(context),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.smd),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          color: hasText ? AppColors.primaryAccent(context) : AppColors.inputBg(context),
                          shape: BoxShape.circle,
                          boxShadow: hasText ? [
                            BoxShadow(
                              color: AppColors.primaryAccent(context).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ] : [],
                        ),
                        child: IconButton(
                          icon: Icon(
                            LucideIcons.send, 
                            size: 18,
                            color: hasText ? Colors.white : AppColors.txtMuted(context),
                          ).animate(target: hasText ? 1 : 0)
                           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 200.ms)
                           .tint(color: Colors.white),
                          onPressed: hasText ? _sendMessage : null,
                        ),
                      ).animate(target: hasText ? 1 : 0)
                       .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 200.ms, curve: Curves.easeOutBack);
                    },
                  ),
                ],
              ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String messageId,
    required String content,
    required bool isMe,
    required String senderName,
    required DateTime timestamp,
    required bool showAvatar,
    VoidCallback? onLongPress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              AtlasAvatar.small(name: senderName)
            else
              const SizedBox(width: 32),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
                    child: Text(
                      senderName,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtSecondary(context),
                      ),
                    ),
                  ),
                GestureDetector(
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
                    decoration: BoxDecoration(
                      color: isMe ? null : AppColors.inputBg(context),
                      gradient: isMe ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryAccent(context),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppRadii.card),
                        topRight: const Radius.circular(AppRadii.card),
                        bottomLeft: Radius.circular(isMe || !showAvatar ? AppRadii.card : 4),
                        bottomRight: Radius.circular(isMe && showAvatar ? 4 : AppRadii.card),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isMe 
                              ? AppColors.primaryAccent(context).withValues(alpha: 0.25) 
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      content,
                      style: AppTextStyles.body.copyWith(
                        color: isMe ? Colors.white : AppColors.txtPrimary(context),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
                  child: Text(
                    DateFormat('h:mm a').format(timestamp),
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
