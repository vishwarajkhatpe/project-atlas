import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/member_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../trips/presentation/trip_controller.dart';

// Provider for fetching members of a specific trip
final tripMembersProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(memberRepositoryProvider);
  
  final channel = Supabase.instance.client.channel('members_$tripId').onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'trip_members',
    filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'trip_id', value: tripId),
    callback: (payload) {
      ref.invalidateSelf();
    },
  )..subscribe();

  ref.onDispose(() {
    Supabase.instance.client.removeChannel(channel);
  });
  
  return repo.getTripMembers(tripId);
});

// Provider for fetching pending invitations for a specific trip
final tripInvitationsProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(memberRepositoryProvider);
  
  final channel = Supabase.instance.client.channel('invites_$tripId').onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'trip_invitations',
    filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'trip_id', value: tripId),
    callback: (payload) {
      ref.invalidateSelf();
    },
  )..subscribe();

  ref.onDispose(() {
    Supabase.instance.client.removeChannel(channel);
  });
  
  return repo.getPendingInvitations(tripId);
});

// Provider for fetching pending invitations sent to the current user
final myInvitationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(memberRepositoryProvider);
  // Watch the current user so this re-fetches when auth state initializes
  ref.watch(currentUserProvider);
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
      ref.invalidate(userTripsProvider);
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

  Future<void> removeMember(String tripId, String userId, {String? email}) async {
    state = const AsyncValue.loading();
    try {
      await _repo.removeMember(tripId, userId, email: email);
      ref.invalidate(tripMembersProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
