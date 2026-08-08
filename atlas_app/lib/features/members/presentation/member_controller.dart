import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/member_repository.dart';

// Provider for fetching members of a specific trip
final tripMembersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getTripMembers(tripId);
});

// Provider for fetching pending invitations for a specific trip
final tripInvitationsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getPendingInvitations(tripId);
});

// Provider for fetching pending invitations sent to the current user
final myInvitationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getMyInvitations();
});

final memberControllerProvider = AsyncNotifierProvider<MemberController, void>(() {
  return MemberController();
});

class MemberController extends AsyncNotifier<void> {
  late final MemberRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(memberRepositoryProvider);
    return null;
  }

  Future<void> inviteMember(String tripId, String email, String role) async {
    state = const AsyncValue.loading();
    try {
      await _repo.inviteMember(tripId, email, role);
      ref.invalidate(tripInvitationsProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> acceptInvitation(String invitationId, String tripId, String role) async {
    state = const AsyncValue.loading();
    try {
      await _repo.acceptInvitation(invitationId, tripId, role);
      ref.invalidate(myInvitationsProvider);
      ref.invalidate(tripMembersProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> declineInvitation(String invitationId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.declineInvitation(invitationId);
      ref.invalidate(myInvitationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> cancelInvitation(String invitationId, String tripId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.cancelInvitation(invitationId);
      ref.invalidate(tripInvitationsProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
