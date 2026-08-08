import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/widgets/bouncy_widget.dart';
import '../../../core/widgets/drag_handle.dart';
import 'member_controller.dart';

class InviteMemberSheet extends ConsumerStatefulWidget {
  final String tripId;
  const InviteMemberSheet({super.key, required this.tripId});

  @override
  ConsumerState<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends ConsumerState<InviteMemberSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'member';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _invite() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(memberControllerProvider.notifier).inviteMember(
        widget.tripId,
        _emailController.text,
        _selectedRole,
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
    final isLoading = ref.watch(memberControllerProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DragHandle(),
              Text(
                'Invite Member',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a friend to this trip via email.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(LucideIcons.mail, size: 20),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => 
                  value == null || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(LucideIcons.shield, size: 20),
                ),
                items: const [
                  DropdownMenuItem(value: 'planner', child: Text('Planner')),
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 32),
              BouncyWidget(
                onPressed: isLoading ? null : _invite,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _invite,
                  child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Invitation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
