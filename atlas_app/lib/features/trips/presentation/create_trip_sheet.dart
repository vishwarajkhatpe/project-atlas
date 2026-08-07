import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'trip_controller.dart';
import '../../../core/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';

class CreateTripSheet extends ConsumerStatefulWidget {
  const CreateTripSheet({super.key});

  @override
  ConsumerState<CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends ConsumerState<CreateTripSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(tripControllerProvider.notifier).createTrip(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripControllerProvider);

    ref.listen<AsyncValue>(tripControllerProvider, (_, state) {
      if (!state.isLoading) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        } else {
          // Success!
          context.pop();
        }
      }
    });

    return Padding(
      // Padding to account for keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        color: Colors.white,
        opacity: 0.8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Plan a New Trip',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name (e.g. Hawaii 2026)',
                  prefixIcon: Icon(Icons.flight_takeoff),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: tripState.isLoading ? null : _submit,
                child: tripState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Trip'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
