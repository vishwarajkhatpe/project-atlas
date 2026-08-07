import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(Supabase.instance.client);
});

class TripRepository {
  final SupabaseClient _supabase;

  TripRepository(this._supabase);

  // Fetch all trips for the current user
  Stream<List<Map<String, dynamic>>> getUserTrips() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // We join trips with trip_members to only get trips this user is part of
    return _supabase
        .from('trips')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        // Note: Supabase RLS will automatically filter this down to only trips the user is a member of,
        // so we can just query the trips table directly if RLS is set up.
        // For MVP, we will query it directly.
        .map((data) => data.toList());
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
      'name': name,
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
}
