import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'proposal_controller.dart';
import '../../../core/widgets/drag_handle.dart';
import '../../../core/widgets/atlas_confirm_dialog.dart';

class CreateProposalSheet extends ConsumerStatefulWidget {
  final String tripId;
  const CreateProposalSheet({super.key, required this.tripId});

  @override
  ConsumerState<CreateProposalSheet> createState() => _CreateProposalSheetState();
}

class _CreateProposalSheetState extends ConsumerState<CreateProposalSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'destination';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _propose() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(proposalControllerProvider.notifier).createProposal(
        tripId: widget.tripId,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(proposalControllerProvider).isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_titleController.text.isNotEmpty || _descriptionController.text.isNotEmpty) {
          final shouldPop = await AtlasConfirmDialog.show(
            context: context,
            title: 'Discard Proposal?',
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
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            32.0, 
            32.0, 
            32.0, 
            32.0 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.paddingOf(context).bottom
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DragHandle(),
                Text(
                  'Propose an Idea',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Propose dates, destinations, or activities for the group to vote on.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(LucideIcons.list, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'destination', child: Text('Destination')),
                    DropdownMenuItem(value: 'dates', child: Text('Dates')),
                    DropdownMenuItem(value: 'accommodation', child: Text('Accommodation')),
                    DropdownMenuItem(value: 'activity', child: Text('Activity')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (e.g. "Paris, France" or "Aug 12 - Aug 18")',
                    prefixIcon: Icon(LucideIcons.type, size: 20),
                  ),
                  validator: (value) => 
                    value == null || value.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    prefixIcon: Icon(Icons.notes, size: 20),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _propose,
                  child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Proposal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
