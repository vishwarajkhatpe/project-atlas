import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final theme = Theme.of(context);
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
        title: const Text('Trip Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.message_circle, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Start from bottom
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['user_id'] == currentUserId;
                    final sender = membersMap[message['user_id']];
                    final senderName = sender != null ? (sender['full_name'] ?? 'Unknown') : 'Unknown';
                    final timestamp = DateTime.parse(message['created_at']).toLocal();

                    // Check if previous message (which is actually index + 1 because reverse=true)
                    // was from the same user to avoid repeating avatars
                    bool showAvatar = true;
                    if (index < messages.length - 1) {
                      final prevMessage = messages[index + 1];
                      if (prevMessage['user_id'] == message['user_id']) {
                        showAvatar = false;
                      }
                    }

                    return _buildMessageBubble(
                      context,
                      theme,
                      content: message['content'],
                      isMe: isMe,
                      senderName: senderName,
                      timestamp: timestamp,
                      showAvatar: showAvatar,
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          
          // Chat Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
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
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.send, size: 20),
                      color: theme.colorScheme.onPrimary,
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

  Widget _buildMessageBubble(
    BuildContext context,
    ThemeData theme, {
    required String content,
    required bool isMe,
    required String senderName,
    required DateTime timestamp,
    required bool showAvatar,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showAvatar ? 16.0 : 4.0,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar) ...[
                  Text(
                    senderName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                      bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.jm().format(timestamp), // Just "2:30 PM"
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          if (isMe) const SizedBox(width: 40), // Balance the spacing so messages don't touch the very edge
        ],
      ),
    );
  }
}
