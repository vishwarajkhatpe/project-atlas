import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ItineraryRepository(Supabase.instance.client, prefs);
});

class ItineraryRepository {
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  ItineraryRepository(this._supabase, this._prefs);

  Future<List<Map<String, dynamic>>> getTripEvents(String tripId) async {
    final cacheKey = 'cache_trip_events_$tripId';
    try {
      final response = await _supabase
          .from('itinerary_events')
          .select()
          .eq('trip_id', tripId)
          .order('start_time', ascending: true);
          
      final events = List<Map<String, dynamic>>.from(response);
      await _prefs.setString(cacheKey, jsonEncode(events));
      return events;
    } catch (e) {
      final cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.cast<Map<String, dynamic>>();
      }
      rethrow;
    }
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
    await _supabase.from('itinerary_events').delete().eq('id', eventId).select();
  }
}
