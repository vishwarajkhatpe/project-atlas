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
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_avatar.dart';
import '../../../core/widgets/atlas_empty_state.dart';
import '../../../core/widgets/atlas_loading_skeleton.dart';
import '../../../core/widgets/atlas_error_state.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

import 'dart:ui';
import '../../../core/widgets/atlas_animated_amount.dart';
import 'expense_controller.dart';
import 'add_expense_sheet.dart';
import '../../members/presentation/member_controller.dart';

class LedgerScreen extends ConsumerWidget {
  final String tripId;

  const LedgerScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(tripExpensesProvider(tripId));

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
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddExpenseSheet(tripId: tripId),
              );
            },
          ),
        ],
      ),
      body: expensesState.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const AtlasSkeletonList(),
        error: (error, stack) => AtlasErrorState(
          title: 'Couldn\'t load expenses',
          subtitle: error.toString(),
          onRetry: () => ref.invalidate(tripExpensesProvider(tripId)),
        ),
        data: (expenses) {
          if (expenses.isEmpty) {
            return AtlasEmptyState(
              icon: LucideIcons.wallet,
              title: 'No expenses yet',
              subtitle: 'Track who paid for what.',
              primaryLabel: 'Add Expense',
              onPrimary: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddExpenseSheet(tripId: tripId),
                );
              },
            ).animate().fadeIn();
          }

          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
          final membersAsync = ref.watch(tripMembersProvider(tripId));
          final membersList = membersAsync.value ?? [];
          
          // Bulletproof logic: How many distinct members are there?
          final memberCount = membersList.isNotEmpty ? membersList.length : 1;
          
          // Is the current user actually a member?
          final isMember = membersList.any((m) => m['user_id'] == currentUserId);
          
          final totalCost = expenses.fold<double>(
            0.0,
            (sum, expense) => sum + ((expense['amount'] as num).toDouble()),
          );
          
          // The user's share is only calculated if they are a member
          final userShare = isMember ? (totalCost / memberCount) : 0.0;
          
          final myTotalPaid = expenses.where((e) => e['paid_by'] == currentUserId).fold<double>(
            0.0,
            (sum, expense) => sum + ((expense['amount'] as num).toDouble()),
          );

          // Calculate balance: positive means they paid more than their share (owed money)
          // negative means they owe money.
          final balance = myTotalPaid - userShare;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripExpensesProvider(tripId));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      top: MediaQuery.paddingOf(context).top + kToolbarHeight + AppSpacing.md,
                      bottom: AppSpacing.xl,
                    ),
                    child: AtlasCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBgLight(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.receipt,
                                  color: AppColors.primaryAccent(context),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Total Trip Cost',
                                style: AppTextStyles.cardTitleOf(context).copyWith(color: AppColors.txtSecondary(context)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AtlasAnimatedAmount(
                            value: totalCost,
                            style: AppTextStyles.largeNumeric.copyWith(color: AppColors.primaryAccent(context)),
                            duration: const Duration(milliseconds: 2500),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Divider(color: AppColors.brd(context).withValues(alpha: 0.5), height: 1),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _buildMetricChip(
                                context,
                                icon: LucideIcons.layers,
                                label: '${expenses.length} ${expenses.length == 1 ? 'entry' : 'entries'}',
                              ),
                              if (userShare > 0)
                                _buildMetricChip(
                                  context,
                                  icon: LucideIcons.chart_pie,
                                  label: 'Your share ₹${userShare.toStringAsFixed(0)}',
                                ),
                              if (myTotalPaid > 0)
                                _buildMetricChip(
                                  context,
                                  icon: LucideIcons.user_check,
                                  label: 'You paid ₹${myTotalPaid.toStringAsFixed(0)}',
                                ),
                            ],
                          ),
                          // Dynamic Balance Banner
                          if (balance.abs() > 0.01) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: balance > 0 ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: balance > 0 ? AppColors.success.withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: balance > 0 ? AppColors.success.withValues(alpha: 0.2) : AppColors.danger.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      balance > 0 ? LucideIcons.arrow_down_left : LucideIcons.arrow_up_right,
                                      color: balance > 0 ? AppColors.success : AppColors.danger,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          balance > 0 ? 'You are owed' : 'You owe',
                                          style: AppTextStyles.caption.copyWith(color: balance > 0 ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${balance.abs().toStringAsFixed(2)}',
                                          style: AppTextStyles.sectionTitle.copyWith(color: balance > 0 ? AppColors.success : AppColors.danger),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (totalCost > 0 && isMember) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.circle_check, color: AppColors.success, size: 18),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Settled up',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'You are all clear',
                                          style: AppTextStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  child: Text(
                    'Transaction History',
                    style: AppTextStyles.sectionTitleOf(context),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = expenses[index];
                      return _buildExpenseCard(context, ref, expense)
                          .animate().fadeIn(duration: 400.ms, delay: (index * 60).ms).slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                    },
                    childCount: expenses.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, WidgetRef ref, Map<String, dynamic> expense) {
    final title = expense['title'] as String;
    final amount = num.tryParse(expense['amount'].toString())?.toDouble() ?? 0.0;
    final expenseDate = DateTime.parse(expense['expense_date']);
    final user = expense['users'];
    final paidByName = user != null ? (user['full_name'] ?? 'Unknown') : 'Unknown';
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = expense['paid_by'] == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AtlasCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            AtlasAvatar.medium(name: paidByName),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Paid by $paidByName',
                        style: AppTextStyles.secondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('•', style: AppTextStyles.secondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        DateFormat('MMM d').format(expenseDate),
                        style: AppTextStyles.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                ),
                if (isOwner)
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
                            Text('Delete Expense', style: TextStyle(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await AtlasConfirmDialog.show(
                          context: context,
                          title: 'Delete Expense?',
                          content: 'Are you sure you want to delete this expense?',
                          confirmText: 'Delete',
                          isDestructive: true,
                        );
                        if (confirm) {
                          ref.read(expenseControllerProvider.notifier).deleteExpense(
                            expenseId: expense['id'],
                            tripId: tripId,
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.txtSecondary(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

