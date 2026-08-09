import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import '../../../core/widgets/atlas_loading_skeleton.dart';

import '../../members/presentation/member_controller.dart';
import 'chat_controller.dart';

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
        AtlasSnackbar.error(context, 'Message failed to send. Check your connection.');
      }
    });

    final messagesState = ref.watch(tripMessagesProvider(widget.tripId));
    final membersState = ref.watch(tripMembersProvider(widget.tripId));
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Create a lookup map for fast user details access
    final membersMap = <String, Map<String, dynamic>>{};
    if (membersState is AsyncData) {
      for (final member in membersState.value!) {
        final user = member['users'];
        if (user != null) {
          membersMap[user['id']] = user;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Text(
                              DateFormat.yMMMd().format(timestamp),
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        _buildMessageBubble(
                          content: message['content'],
                          isMe: isMe,
                          senderName: senderName,
                          timestamp: timestamp,
                          showAvatar: showAvatar,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
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
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.smd),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.send, size: 18),
                      color: Colors.white,
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String content,
    required bool isMe,
    required String senderName,
    required DateTime timestamp,
    required bool showAvatar,
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
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
                    child: Text(
                      senderName,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.inputBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadii.card),
                      topRight: const Radius.circular(AppRadii.card),
                      bottomLeft: Radius.circular(isMe || !showAvatar ? AppRadii.card : 4),
                      bottomRight: Radius.circular(isMe && showAvatar ? 4 : AppRadii.card),
                    ),
                  ),
                  child: Text(
                    content,
                    style: AppTextStyles.body.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
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
            // Avatar for me is optional in typical chat UI, skipping to save space
            // If you want it: AtlasAvatar.small(name: 'Me'),
          ],
        ],
      ),
    );
  }
}
