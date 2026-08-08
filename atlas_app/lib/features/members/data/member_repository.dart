import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(Supabase.instance.client);
});

class MemberRepository {
  final SupabaseClient _supabase;

  MemberRepository(this._supabase);

  // Fetch current members of a trip
  Future<List<Map<String, dynamic>>> getTripMembers(String tripId) async {
    final response = await _supabase
        .from('trip_members')
        .select('''
          role,
          joined_at,
          users (
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('trip_id', tripId)
        .order('joined_at', ascending: true);
        
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch pending invitations for a trip
  Future<List<Map<String, dynamic>>> getPendingInvitations(String tripId) async {
    final response = await _supabase
        .from('trip_invitations')
        .select()
        .eq('trip_id', tripId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
        
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch pending invitations for the current user
  Future<List<Map<String, dynamic>>> getMyInvitations() async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) return [];

    final response = await _supabase
        .from('trip_invitations')
        .select('''
          id,
          role,
          created_at,
          trips (
            id,
            title,
            description
          )
        ''')
        .eq('email', email)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
        
    return List<Map<String, dynamic>>.from(response);
  }

  // Invite a member by email
  Future<void> inviteMember(String tripId, String email, String role) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    // Basic email validation
    if (!email.contains('@')) throw Exception('Invalid email format');

    await _supabase.from('trip_invitations').insert({
      'trip_id': tripId,
      'email': email.trim().toLowerCase(),
      'invited_by': userId,
      'role': role,
    });
  }

  // Accept an invitation
  Future<void> acceptInvitation(String invitationId, String tripId, String role) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    // 1. Update invitation status
    await _supabase.from('trip_invitations').update({
      'status': 'accepted',
    }).eq('id', invitationId);

    // 2. Add to trip_members
    await _supabase.from('trip_members').insert({
      'trip_id': tripId,
      'user_id': userId,
      'role': role,
    });
  }

  // Decline an invitation
  Future<void> declineInvitation(String invitationId) async {
    await _supabase.from('trip_invitations').update({
      'status': 'declined',
    }).eq('id', invitationId);
  }

  // Cancel an invitation (delete it)
  Future<void> cancelInvitation(String invitationId) async {
    await _supabase.from('trip_invitations').delete().eq('id', invitationId);
  }

  // Remove a member from a trip
  Future<void> removeMember(String tripId, String userId) async {
    await _supabase.from('trip_members').delete().eq('trip_id', tripId).eq('user_id', userId);
  }
}
