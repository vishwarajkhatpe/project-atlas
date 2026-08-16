import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/atlas_avatar.dart';
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
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final show = _scrollController.offset > 200;
      if (show != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = show;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _sendMessage([String? customText]) {
    final content = (customText ?? _messageController.text).trim();
    if (content.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();
    ref.read(chatControllerProvider.notifier).sendMessage(
          tripId: widget.tripId,
          content: content,
        );
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  void _showMessageOptions({
    required BuildContext context,
    required String messageId,
    required String content,
    required bool isMe,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = AppColors.isDark(context);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.brd(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.txtMuted(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(LucideIcons.copy, color: AppColors.primaryAccent(context)),
                  title: Text('Copy message', style: AppTextStyles.bodyOf(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: content));
                    Navigator.pop(sheetContext);
                    HapticFeedback.lightImpact();
                    AtlasSnackbar.success(context, 'Message copied to clipboard');
                  },
                ),
                if (isMe) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.trash_2, color: AppColors.danger),
                    title: const Text(
                      'Delete message',
                      style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final shouldDelete = await AtlasConfirmDialog.show(
                        context: context,
                        title: 'Delete Message?',
                        content: 'This message will be deleted for all members of the trip.',
                        confirmText: 'Delete',
                        isDestructive: true,
                      );
                      if (shouldDelete == true && context.mounted) {
                        final success = await ref
                            .read(chatControllerProvider.notifier)
                            .deleteMessage(messageId);
                        if (success && context.mounted) {
                          ref.invalidate(tripMessagesProvider(widget.tripId));
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(chatControllerProvider, (previous, next) {
      if (next.hasError) {
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

    // Create a fast lookup map for member profiles
    final membersMap = <String, Map<String, dynamic>>{};
    final membersList = membersState.value ?? [];
    for (final member in membersList) {
      final user = member['users'] ?? member['profile'];
      final uid = member['user_id'] ?? member['id'] ?? (user != null ? user['id'] : null);
      if (uid != null) {
        membersMap[uid.toString()] = {
          'full_name': user != null ? (user['full_name'] ?? 'Traveler') : (member['full_name'] ?? 'Traveler'),
          'avatar_url': user != null ? user['avatar_url'] : member['avatar_url'],
        };
      }
    }

    final memberCount = membersList.length;
    final isDark = AppColors.isDark(context);
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = viewInsetsBottom > 0;
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    // Razor-tight gap (4px) above the floating bottom navigation bar
    // Floating Nav Bar height is 64 + 8px bottom margin = 72px + bottomSafeArea.
    final double inputBottomOffset = isKeyboardOpen
        ? viewInsetsBottom + 8.0
        : bottomSafeArea + 74.0;

    final double listBottomPadding = inputBottomOffset + 54.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.brd(context).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent(context),
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent(context).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(LucideIcons.message_square, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Group Chat',
                    style: AppTextStyles.cardTitleOf(context).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        memberCount > 0
                            ? '$memberCount traveler${memberCount == 1 ? '' : 's'} active'
                            : 'Live group discussion',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.txtMuted(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.inputBg(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.brd(context).withValues(alpha: 0.5)),
              ),
              child: Icon(
                LucideIcons.users,
                size: 16,
                color: AppColors.txtPrimary(context),
              ),
            ),
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
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight + AppSpacing.md,
                    bottom: listBottomPadding,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['user_id'] == currentUserId;
                    final senderInfo = membersMap[message['user_id']];
                    final senderName = senderInfo != null ? senderInfo['full_name'] ?? 'Traveler' : 'Traveler';
                    final senderAvatarUrl = senderInfo != null ? senderInfo['avatar_url'] : null;
                    final timestamp = DateTime.parse(message['created_at']).toLocal();

                    // Check if consecutive from same user (to group bubbles cleanly)
                    bool isFirstInGroup = true;
                    if (index < messages.length - 1) {
                      final nextMessage = messages[index + 1];
                      if (nextMessage['user_id'] == message['user_id']) {
                        final nextTime = DateTime.parse(nextMessage['created_at']).toLocal();
                        if (timestamp.difference(nextTime).inMinutes.abs() < 3) {
                          isFirstInGroup = false;
                        }
                      }
                    }

                    // Check if date divider is needed
                    bool showDateDivider = false;
                    if (index == messages.length - 1) {
                      showDateDivider = true;
                    } else {
                      final prevMessageDate = DateTime.parse(messages[index + 1]['created_at']).toLocal();
                      if (timestamp.difference(prevMessageDate).inDays.abs() > 0 || timestamp.day != prevMessageDate.day) {
                        showDateDivider = true;
                      }
                    }

                    return Column(
                      key: ValueKey(message['id']),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showDateDivider) _buildDateDivider(timestamp),
                        _buildMessageBubble(
                          messageId: message['id'].toString(),
                          content: message['content'] ?? '',
                          isMe: isMe,
                          senderName: senderName,
                          avatarUrl: senderAvatarUrl,
                          timestamp: timestamp,
                          showAvatar: isFirstInGroup,
                          onLongPress: () => _showMessageOptions(
                            context: context,
                            messageId: message['id'].toString(),
                            content: message['content'] ?? '',
                            isMe: isMe,
                          ),
                        ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0, duration: 220.ms, curve: Curves.easeOutCubic),
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

          // Scroll to bottom floating button
          if (_showScrollToBottom)
            Positioned(
              right: AppSpacing.md,
              bottom: inputBottomOffset + 60,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.brd(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.arrow_down,
                        size: 14,
                        color: AppColors.primaryAccent(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Latest',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8), duration: 200.ms),
            ),

          // Floating Glassmorphic Input Bar
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: inputBottomOffset,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent(context).withValues(alpha: isDark ? 0.12 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          minLines: 1,
                          style: AppTextStyles.bodyOf(context).copyWith(
                            fontSize: 14,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Share ideas or updates...',
                            hintStyle: AppTextStyles.secondary.copyWith(
                              color: AppColors.txtMuted(context).withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _messageController,
                        builder: (context, value, child) {
                          final hasText = value.text.trim().isNotEmpty;
                          final accent = AppColors.primaryAccent(context);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(bottom: 2),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: hasText
                                  ? LinearGradient(
                                      colors: [accent, AppColors.primaryDark],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: hasText ? null : AppColors.inputBg(context),
                              shape: BoxShape.circle,
                              boxShadow: hasText
                                  ? [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: IconButton(
                              icon: Icon(
                                LucideIcons.arrow_up,
                                size: 18,
                                color: hasText ? Colors.white : AppColors.txtMuted(context),
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: hasText ? () => _sendMessage() : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day;
    final isYesterday = timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day - 1;

    String dateLabel = DateFormat('MMMM d, yyyy').format(timestamp);
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cardBg(context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.brd(context).withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            dateLabel,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w600,
              color: AppColors.txtSecondary(context),
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent(context).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.message_circle,
                size: 34,
                color: AppColors.primaryAccent(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Trip Chat is Empty',
              style: AppTextStyles.cardTitleOf(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Coordinate plans, share recommendations, or start the conversation with your crew.',
                textAlign: TextAlign.center,
                style: AppTextStyles.secondaryOf(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip('👋 Hey crew! Excited for this trip'),
                _buildPromptChip('📍 Found a great place we should visit'),
                _buildPromptChip('🍕 What time are we meeting up?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return GestureDetector(
      onTap: () => _sendMessage(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.brd(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          prompt,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryAccent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String messageId,
    required String content,
    required bool isMe,
    required String senderName,
    String? avatarUrl,
    required DateTime timestamp,
    required bool showAvatar,
    VoidCallback? onLongPress,
  }) {
    final isDark = AppColors.isDark(context);
    final accent = AppColors.primaryAccent(context);

    return Padding(
      padding: EdgeInsets.only(bottom: showAvatar ? AppSpacing.sm : 3.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              AtlasAvatar.small(
                name: senderName,
                imageUrl: avatarUrl,
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 3),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                        color: AppColors.txtSecondary(context),
                      ),
                    ),
                  ),
                GestureDetector(
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [accent, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : AppColors.cardBg(context),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : (showAvatar ? 4 : 18)),
                        bottomRight: Radius.circular(isMe ? (showAvatar ? 4 : 18) : 18),
                      ),
                      border: isMe
                          ? null
                          : Border.all(
                              color: AppColors.brd(context).withValues(alpha: 0.8),
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isMe
                              ? accent.withValues(alpha: isDark ? 0.3 : 0.2)
                              : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          content,
                          style: AppTextStyles.bodyOf(context).copyWith(
                            color: isMe ? Colors.white : AppColors.txtPrimary(context),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(timestamp),
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : AppColors.txtMuted(context),
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 3),
                              Icon(
                                LucideIcons.check_check,
                                size: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

