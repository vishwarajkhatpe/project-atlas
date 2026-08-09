import 'package:flutter/material.dart';
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

import 'itinerary_controller.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final String tripId;
  const AddEventSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: (TimeOfDay.now().hour + 1) % 24);

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      AtlasSnackbar.error(context, 'End time must be after start time');
      return;
    }

    try {
      await ref.read(itineraryControllerProvider.notifier).addEvent(
        tripId: widget.tripId,
        title: _titleController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text.isNotEmpty ? _locationController.text.trim() : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text.trim() : null,
      );
      if (mounted) {
        AtlasSnackbar.success(context, 'Event added to schedule');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AtlasSnackbar.error(context, e.toString());
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
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
        if (isStart) {
          _startTime = picked;
          // Auto-adjust end time if it's before start time
          final startMins = _startTime.hour * 60 + _startTime.minute;
          final endMins = _endTime.hour * 60 + _endTime.minute;
          if (endMins <= startMins) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(itineraryControllerProvider).isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_titleController.text.isNotEmpty || _locationController.text.isNotEmpty || _descriptionController.text.isNotEmpty) {
          final shouldPop = await AtlasConfirmDialog.show(
            context: context,
            title: 'Discard Event?',
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
      child: Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, 
          AppSpacing.xl, 
          AppSpacing.xl, 
          AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom + MediaQuery.paddingOf(context).bottom
        ),
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
                'What are you planning?',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add an activity, flight, or reservation to the schedule.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              AtlasTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'e.g. Flight to Honolulu',
                prefixIcon: LucideIcons.type,
                validator: (value) => 
                  value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Date Row
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
                            Text('Date', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
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
              const SizedBox(height: AppSpacing.md),
              
              // Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: AppRadii.cardRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.clock, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: AppSpacing.smd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _startTime.format(context),
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: AppRadii.cardRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.clock, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: AppSpacing.smd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('End', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _endTime.format(context),
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              AtlasTextField(
                controller: _locationController,
                label: 'Location (Optional)',
                hint: 'e.g. Terminal 1, Gate A',
                prefixIcon: LucideIcons.map_pin,
              ),
              const SizedBox(height: AppSpacing.lg),
              AtlasTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add confirmation numbers, notes, etc.',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AtlasButton(
                label: 'Add to Schedule',
                isLoading: isLoading,
                onPressed: isLoading ? null : _addEvent,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
