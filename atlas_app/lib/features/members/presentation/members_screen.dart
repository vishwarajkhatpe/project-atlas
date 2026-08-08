import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/widgets/app_card.dart';
import 'member_controller.dart';
import 'invite_member_sheet.dart';

class MembersScreen extends ConsumerWidget {
  final String tripId;
  const MembersScreen({super.key, required this.tripId});

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteMemberSheet(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final invitesAsync = ref.watch(tripInvitationsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.user_plus),
            onPressed: () => _showInviteSheet(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Pending Invitations
          invitesAsync.when(
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
                            _buildInviteCard(theme, invite),
                          ],
                        );
                      }
                      return _buildInviteCard(theme, invite);
                    },
                    childCount: invites.length,
                  ),
                ),
              );
            },
          ),
          
          // Current Members
          membersAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
            data: (members) {
              return SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final member = members[index];
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Members',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMemberCard(theme, member),
                          ],
                        );
                      }
                      return _buildMemberCard(theme, member);
                    },
                    childCount: members.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(ThemeData theme, Map<String, dynamic> invite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(LucideIcons.mail, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invite['email'] ?? 'Unknown',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7), // Amber 100
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pending',
                          style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFFD97706)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Invited as ${invite['role']}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                return IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: theme.colorScheme.error,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Invitation?'),
                        content: const Text('Are you sure you want to cancel this invitation?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Keep'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await ref.read(memberControllerProvider.notifier).cancelInvitation(invite['id'], tripId);
                                if (context.mounted) Navigator.of(context).pop();
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to cancel: $e')),
                                  );
                                }
                              }
                            },
                            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.error)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(ThemeData theme, Map<String, dynamic> member) {
    final user = member['users'];
    final name = user != null ? (user['full_name'] ?? 'Unknown') : 'Unknown';
    final role = member['role'] ?? 'member';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: role == 'owner' ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: role == 'owner' ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
            if (role != 'owner')
              Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    icon: const Icon(LucideIcons.user_minus, size: 20),
                    color: theme.colorScheme.error,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Member?'),
                          content: Text('Are you sure you want to remove $name from this trip?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await ref.read(memberControllerProvider.notifier).removeMember(widget.tripId, user['id']);
                                  if (context.mounted) Navigator.of(context).pop();
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to remove: $e')),
                                    );
                                  }
                                }
                              },
                              child: Text('Remove', style: TextStyle(color: theme.colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
