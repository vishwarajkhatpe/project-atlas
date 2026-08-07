import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../auth/presentation/auth_controller.dart';
import 'trip_controller.dart';
import '../../../core/widgets/glass_container.dart';
import 'create_trip_sheet.dart';

class TripsDashboardScreen extends ConsumerStatefulWidget {
  const TripsDashboardScreen({super.key});

  @override
  ConsumerState<TripsDashboardScreen> createState() => _TripsDashboardScreenState();
}

class _TripsDashboardScreenState extends ConsumerState<TripsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _showCreateTripSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTripSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(userTripsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTripSheet,
        icon: const Icon(Icons.flight_takeoff),
        label: const Text('New Trip'),
      ),
      body: Stack(
        children: [
          // Animated Vibrant Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _bgController.value * 2 * math.pi,
                child: Transform.scale(
                  scale: 2.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFF6366F1), // Indigo
                          Color(0xFFEC4899), // Pink
                          Color(0xFF14B8A6), // Teal
                          Color(0xFF6366F1), // Indigo again to loop
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
          // Content
          SafeArea(
            child: tripsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (err, _) => Center(
                child: GlassContainer(
                  color: Colors.red,
                  child: Text('Error loading trips: $err'),
                ),
              ),
              data: (trips) {
                if (trips.isEmpty) {
                  return Center(
                    child: GlassContainer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_off, size: 64, color: theme.colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'No trips yet!',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Start your first adventure today.'),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip['name'] ?? 'Unnamed Trip',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (trip['description'] != null && trip['description'].isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(trip['description']),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.date_range, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  trip['start_date'] != null
                                      ? trip['start_date'].toString().split(' ')[0] // simple format
                                      : 'Dates TBD',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
