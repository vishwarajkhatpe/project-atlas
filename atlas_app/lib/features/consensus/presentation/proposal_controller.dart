import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/proposal_repository.dart';

// Provider for fetching active proposals for a specific trip
final tripProposalsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(proposalRepositoryProvider);
  return repo.getTripProposals(tripId);
});

final proposalControllerProvider = AsyncNotifierProvider<ProposalController, void>(() {
  return ProposalController();
});

class ProposalController extends AsyncNotifier<void> {
  late final ProposalRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(proposalRepositoryProvider);
    return null;
  }

  Future<void> createProposal({
    required String tripId,
    required String type,
    required String title,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createProposal(
        tripId: tripId,
        type: type,
        title: title,
        description: description,
      );
      ref.invalidate(tripProposalsProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> castVote({
    required String tripId,
    required String proposalId,
    required String voteValue,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.castVote(proposalId: proposalId, voteValue: voteValue);
      ref.invalidate(tripProposalsProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> resolveProposal(String tripId, String proposalId, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repo.resolveProposal(proposalId, status);
      ref.invalidate(tripProposalsProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteProposal({
    required String tripId,
    required String proposalId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteProposal(proposalId);
      ref.invalidate(tripProposalsProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
