import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final proposalRepositoryProvider = Provider<ProposalRepository>((ref) {
  return ProposalRepository(Supabase.instance.client);
});

class ProposalRepository {
  final SupabaseClient _supabase;

  ProposalRepository(this._supabase);

  // Fetch all active proposals for a trip, including votes and proposer info
  Future<List<Map<String, dynamic>>> getTripProposals(String tripId) async {
    final response = await _supabase
        .from('proposals')
        .select('''
          *,
          users (
            id,
            full_name,
            avatar_url
          ),
          votes (
            user_id,
            vote
          )
        ''')
        .eq('trip_id', tripId)
        .order('created_at', ascending: false);
        
    return List<Map<String, dynamic>>.from(response);
  }

  // Create a new proposal
  Future<void> createProposal({
    required String tripId,
    required String type,
    required String title,
    String? description,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    await _supabase.from('proposals').insert({
      'trip_id': tripId,
      'proposed_by': userId,
      'type': type,
      'title': title,
      'description': description,
    });
  }

  // Cast or update a vote on a proposal
  Future<void> castVote({
    required String proposalId,
    required String voteValue, // 'approve', 'reject', 'abstain'
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    // Use upsert to handle both insert and update natively
    await _supabase.from('votes').upsert({
      'proposal_id': proposalId,
      'user_id': userId,
      'vote': voteValue,
    }, onConflict: 'proposal_id, user_id');
  }

  // Resolve a proposal (planner/owner only)
  Future<void> resolveProposal(String proposalId, String status) async {
    await _supabase.from('proposals').update({
      'status': status,
    }).eq('id', proposalId);
  }

  // Delete a proposal
  Future<void> deleteProposal(String proposalId) async {
    await _supabase.from('proposals').delete().eq('id', proposalId).select();
  }
}
