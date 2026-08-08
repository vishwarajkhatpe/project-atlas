import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(Supabase.instance.client);
});

class ItineraryRepository {
  final SupabaseClient _supabase;

  ItineraryRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getTripEvents(String tripId) async {
    final response = await _supabase
        .from('itinerary_events')
        .select()
        .eq('trip_id', tripId)
        .order('start_time', ascending: true);
        
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addEvent({
    required String tripId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    await _supabase.from('itinerary_events').insert({
      'trip_id': tripId,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'description': description,
      'created_by': userId,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('itinerary_events').delete().eq('id', eventId);
  }
}
