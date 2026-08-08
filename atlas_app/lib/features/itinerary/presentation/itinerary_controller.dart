import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/itinerary_repository.dart';

final tripItineraryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(itineraryRepositoryProvider);
  return repo.getTripEvents(tripId);
});

final itineraryControllerProvider = AsyncNotifierProvider<ItineraryController, void>(() {
  return ItineraryController();
});

class ItineraryController extends AsyncNotifier<void> {
  late final ItineraryRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(itineraryRepositoryProvider);
    return null;
  }

  Future<void> addEvent({
    required String tripId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addEvent(
        tripId: tripId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
      );
      ref.invalidate(tripItineraryProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteEvent(String tripId, String eventId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteEvent(eventId);
      ref.invalidate(tripItineraryProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
