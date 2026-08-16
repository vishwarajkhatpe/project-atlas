import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TripRepository(Supabase.instance.client, prefs);
});

class TripRepository {
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  TripRepository(this._supabase, this._prefs);

  // Fetch all trips for the current user
  Future<List<Map<String, dynamic>>> getUserTrips() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final cacheKey = 'cache_user_trips_$userId';
    
    try {
      final response = await _supabase
          .from('trip_members')
          .select('''
            role,
            trips!inner (*)
          ''')
          .eq('user_id', userId);
          
      // Extract the nested trip objects, sort by created_at descending
      final trips = response.map((row) => row['trips'] as Map<String, dynamic>).toList();
      trips.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
      
      // Save to cache
      await _prefs.setString(cacheKey, jsonEncode(trips));
      
      return trips;
    } catch (e) {
      // If network fails, try to load from cache
      final cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.cast<Map<String, dynamic>>();
      }
      rethrow;
    }
  }

  // Create a new trip
  Future<void> createTrip({
    required String name,
    required String description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to create a trip');

    // 1. Insert the trip
    final tripResponse = await _supabase.from('trips').insert({
      'title': name,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_by': userId,
    }).select().single();

    final tripId = tripResponse['id'];

    // 2. Insert the owner into trip_members
    await _supabase.from('trip_members').insert({
      'trip_id': tripId,
      'user_id': userId,
      'role': 'owner',
    });
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    final deleted = await _supabase.from('trips').delete().eq('id', tripId).select();
    if (deleted.isEmpty) {
      throw Exception('Failed to delete trip. Only the trip owner can delete it.');
    }
  }

  // Update a trip
  Future<void> updateTrip(
    String tripId, {
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _supabase.from('trips').update({
      'title': name,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    }).eq('id', tripId);
  }

  // Join a trip via deep link UUID
  Future<void> joinTrip(String tripId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in to join a trip.');

    await _supabase.from('trip_members').insert({
      'trip_id': tripId,
      'user_id': userId,
      'role': 'member',
    });
  }
}
