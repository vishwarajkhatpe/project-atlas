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

import 'expense_controller.dart';
import 'add_expense_sheet.dart';

class LedgerScreen extends ConsumerWidget {
  final String tripId;

  const LedgerScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(tripExpensesProvider(tripId));

    return Scaffold(
      appBar: AppBar(
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

          final totalCost = expenses.fold<double>(
            0.0,
            (sum, expense) => sum + ((expense['amount'] as num).toDouble()),
          );

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
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
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.receipt,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Total Trip Cost',
                              style: AppTextStyles.cardTitle.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '₹${totalCost.toStringAsFixed(2)}',
                          style: AppTextStyles.largeNumeric.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  child: Text(
                    'Expense Log',
                    style: AppTextStyles.sectionTitle,
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
}
