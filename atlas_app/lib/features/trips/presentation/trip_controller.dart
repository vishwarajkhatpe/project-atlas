import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trip_repository.dart';

// Stream of user trips
final userTripsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(tripRepositoryProvider);
  return repo.getUserTrips();
});

// Controller to handle creating trips
final tripControllerProvider = AsyncNotifierProvider<TripController, void>(() {
  return TripController();
});

class TripController extends AsyncNotifier<void> {
  late final TripRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(tripRepositoryProvider);
    return null;
  }

  Future<void> createTrip({
    required String name,
    required String description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createTrip(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
