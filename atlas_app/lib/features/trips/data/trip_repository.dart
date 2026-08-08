import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(Supabase.instance.client);
});

class TripRepository {
  final SupabaseClient _supabase;

  TripRepository(this._supabase);

  // Fetch all trips for the current user
  Future<List<Map<String, dynamic>>> getUserTrips() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('trips')
        .select()
        .order('created_at', ascending: false);
        
    return List<Map<String, dynamic>>.from(response);
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
    await _supabase.from('trips').delete().eq('id', tripId);
  }
}
