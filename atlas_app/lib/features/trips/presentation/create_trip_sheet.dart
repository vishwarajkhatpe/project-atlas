import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

import 'trip_controller.dart';

class CreateTripSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialTrip;

  const CreateTripSheet({super.key, this.initialTrip});

  @override
  ConsumerState<CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends ConsumerState<CreateTripSheet> {
  int _currentStep = 0; // 0 = Name/Dest, 1 = Dates
  
  final _nameController = TextEditingController();
  final _destController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTimeRange? _dateRange;
  bool _decideLater = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTrip != null) {
      final trip = widget.initialTrip!;
      _nameController.text = trip['title'] ?? '';
      _destController.text = trip['description'] ?? ''; // Using description as destination for now
      if (trip['start_date'] != null && trip['end_date'] != null) {
        _dateRange = DateTimeRange(
          start: DateTime.parse(trip['start_date']),
          end: DateTime.parse(trip['end_date']),
        );
      } else {
        _decideLater = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _submit() {
    if (_currentStep == 1 && _dateRange == null && !_decideLater) {
      AtlasSnackbar.error(context, 'Please select dates or choose "I\'ll decide later"');
      return;
    }

    if (widget.initialTrip != null) {
      ref.read(tripControllerProvider.notifier).updateTrip(
        tripId: widget.initialTrip!['id'],
        name: _nameController.text.trim(),
        description: _destController.text.trim(),
        startDate: _decideLater ? null : _dateRange?.start,
        endDate: _decideLater ? null : _dateRange?.end,
      );
    } else {
      ref.read(tripControllerProvider.notifier).createTrip(
          name: _nameController.text.trim(),
          description: _destController.text.trim(),
          startDate: _decideLater ? null : _dateRange?.start,
          endDate: _decideLater ? null : _dateRange?.end,
        );
    }
  }

  Future<void> _pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDateRange: _dateRange,
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
        _dateRange = picked;
        _decideLater = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripControllerProvider);

    ref.listen<AsyncValue>(tripControllerProvider, (previous, state) {
      if (previous != null && previous.isLoading && !state.isLoading) {
        if (state.hasError) {
          final actionStr = widget.initialTrip != null ? 'update' : 'create';
          AtlasSnackbar.error(context, 'Failed to $actionStr trip: ${state.error}');
        } else {
          HapticFeedback.lightImpact();
          final actionStr = widget.initialTrip != null ? 'updated' : 'created';
          AtlasSnackbar.success(context, 'Trip $actionStr successfully');
          context.pop();
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_nameController.text.isNotEmpty || _destController.text.isNotEmpty || _dateRange != null) {
          final shouldPop = await AtlasConfirmDialog.show(
            context: context,
            title: 'Discard Trip?',
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, 
          AppSpacing.xl, 
          AppSpacing.xl, 
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom
        ),
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
            
            // Progress Indicator
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadii.pillRadius,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentStep == 1 ? AppColors.primary : AppColors.inputBackground,
                      borderRadius: AppRadii.pillRadius,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            if (_currentStep == 0) ...[
              Text(
                widget.initialTrip != null ? 'Edit Trip' : 'Where are we going?',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.initialTrip != null ? 'Update your trip details.' : 'Give your trip a name and destination.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AtlasTextField(
                      controller: _nameController,
                      label: 'Trip Name',
                      hint: 'e.g. Hawaii 2026',
                      prefixIcon: LucideIcons.map,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AtlasTextField(
                      controller: _destController,
                      label: 'Destination (Optional)',
                      hint: 'e.g. Honolulu, HI',
                      prefixIcon: LucideIcons.map_pin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AtlasButton(
                label: 'Next',
                onPressed: _nextStep,
              ),
            ] else ...[
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrow_left),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _currentStep = 0),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    widget.initialTrip != null ? 'Update Dates' : 'When is the trip?',
                    style: AppTextStyles.pageTitle,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select dates or decide later.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              GestureDetector(
                onTap: _pickDates,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: AppRadii.cardRadius,
                    border: Border.all(
                      color: _dateRange != null && !_decideLater ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        color: _dateRange != null && !_decideLater ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _dateRange != null && !_decideLater
                              ? '${DateFormat('MMM d, yyyy').format(_dateRange!.start)} – ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}'
                              : 'Select Dates',
                          style: AppTextStyles.body.copyWith(
                            color: _dateRange != null && !_decideLater ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: _dateRange != null && !_decideLater ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Checkbox(
                    value: _decideLater,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _decideLater = value ?? false;
                        if (_decideLater) _dateRange = null;
                      });
                    },
                  ),
                  Text(
                    'I\'ll decide later',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              AtlasButton(
                label: 'Create Trip',
                isLoading: tripState.isLoading,
                onPressed: (tripState.isLoading || (_dateRange == null && !_decideLater))
                    ? null
                    : _submit,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      ),
    );
  }
}
