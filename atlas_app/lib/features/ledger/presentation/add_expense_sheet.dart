import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_button.dart';
import '../../../core/widgets/atlas_text_field.dart';
import '../../../core/widgets/atlas_snackbar.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

import 'expense_controller.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final String tripId;

  const AddExpenseSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(expenseControllerProvider.notifier).addExpense(
              tripId: widget.tripId,
              title: _titleController.text.trim(),
              amount: double.parse(_amountController.text.trim()),
              expenseDate: _selectedDate,
            );
        if (mounted) {
          AtlasSnackbar.success(context, 'Expense added successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          AtlasSnackbar.error(context, e.toString());
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(expenseControllerProvider).isLoading;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_titleController.text.isNotEmpty || _amountController.text.isNotEmpty) {
          final shouldPop = await AtlasConfirmDialog.show(
            context: context,
            title: 'Discard Expense?',
            content: 'You have entered some information. Are you sure you want to discard it?',
            confirmText: 'Discard',
            isDestructive: true,
          );
          if (shouldPop == true && context.mounted) {
            context.pop();
          }
        } else {
          context.pop();
        }
      },
      child: Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: AppRadii.pillRadius,
                    ),
                  ),
                ),
                Text(
                  'Add Expense',
                  style: AppTextStyles.pageTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AtlasTextField(
                  controller: _titleController,
                  label: 'What was it for?',
                  hint: 'e.g. Dinner, Taxi, Hotel',
                  prefixIcon: LucideIcons.receipt,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AtlasTextField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: LucideIcons.indian_rupee,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.calendar, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date Paid', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM d, yyyy').format(_selectedDate),
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AtlasButton(
                  label: 'Save Expense',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
