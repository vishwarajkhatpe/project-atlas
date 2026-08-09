# Project Atlas — Principal Engineer Code & Product Review

## Executive Summary

The bones of this app are genuinely solid for an MVP: a clean design-token system (`app_colors.dart`, `app_spacing.dart`, `app_radii.dart`), consistent Riverpod usage (`AsyncNotifier` + `FutureProvider.family`), and disciplined `dispose()` hygiene across every form sheet — that last part is rare to see done this consistently in a fast-moving prototype, so credit where due.

That said, my pass through the actual data flow surfaced something important: **the flagship product pillar — "Consensus Before Commitment" — is not actually wired end-to-end.** Proposals can be voted on, but nothing ever flips a proposal's status away from `pending`, and a downstream screen is silently checking for a status value (`'open'`) that doesn't even exist in your Postgres enum. That's not a nitpick — it's the core differentiator from your own PRD not functioning. I also found a completely non-functional "Remove Member" action, a real-time collaboration story that only covers chat (despite Volume 01 calling real-time collaboration a core pillar), and a Riverpod/GoRouter wiring bug that will silently reset users to the dashboard root roughly every hour when Supabase refreshes their JWT.

None of this is "the app is broken" — it's "the last 10% of wiring didn't get finished before the redesign sprint," which is exactly the kind of thing a pre-launch audit should catch.

---

## 1. 🚀 Strategic Product & Feature Improvements

### 1.1 The Consensus engine doesn't actually reach consensus (highest priority)
`proposals.status` is a Postgres enum: `'pending' | 'approved' | 'rejected'` (`supabase/schema.sql`). Nothing in the app ever transitions a proposal out of `pending` — `ProposalController.resolveProposal()` exists but is **never called from any widget**. Votes are cast and stored, but a proposal with 5/5 "Agree" votes looks identical in the UI to one with 0 votes. This also explains why `backlogs.md` lists "Tie approved proposals into the Itinerary" as not-done — there's nothing to tie in yet.

**Recommendation:** either (a) add a manual "Finalize" action for owners/planners, or (b) auto-resolve via a Postgres trigger once every member has voted. Minimal manual fix, in `atlas_app/lib/features/consensus/presentation/proposal_card.dart` (requires passing the viewer's trip role down, the same way `members_screen.dart` already does):

```dart
if (canResolve && proposal['status'] == 'pending') ...[
  const SizedBox(height: AppSpacing.md),
  Row(
    children: [
      Expanded(
        child: AtlasSecondaryButton(
          label: 'Reject',
          onPressed: () => ref.read(proposalControllerProvider.notifier)
              .resolveProposal(tripId, proposal['id'], 'rejected'),
        ),
      ),
      const SizedBox(width: AppSpacing.smd),
      Expanded(
        child: AtlasButton(
          label: 'Finalize',
          onPressed: () => ref.read(proposalControllerProvider.notifier)
              .resolveProposal(tripId, proposal['id'], 'approved'),
        ),
      ),
    ],
  ),
],
```

### 1.2 Invitations are never actually delivered
`MemberRepository.inviteMember()` only inserts a row into `trip_invitations`. There is no email/push sent. An invited person only finds out if they already have the app installed, are logged in, and happen to open the dashboard. For a "collaborative" app, this is the #1 activation blocker — most invitees will simply never see the invite. This needs a Supabase Edge Function (on `INSERT` to `trip_invitations`) that sends a transactional email with a deep link.

### 1.3 No push notification hooks anywhere
Volume 01 names Firebase Cloud Messaging as part of the stack; there's zero FCM wiring in the repo. At minimum you need triggers for: new proposal to vote on, new chat message, invite received, expense added. Without this, "real-time collaboration" only works while the app is open and foregrounded.

### 1.4 Ledger has no splitting or settlement — it's an expense log, not a "ledger"
`expenses` table tracks `paid_by` and `amount` only. There's no `expense_splits` table, so the app can never answer "who owes whom." Given the PRD explicitly names Splitwise as a pain point you're solving, this is a gap between the pitch and the product. Minimal schema addition:

```sql
CREATE TABLE public.expense_splits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id UUID REFERENCES public.expenses(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    share_amount NUMERIC(10,2) NOT NULL,
    UNIQUE(expense_id, user_id)
);
```
...plus a "net balances" view/screen in `ledger_screen.dart`.

### 1.5 `trips.cover_image_url` already exists in the schema but is entirely unused
`trips_dashboard_screen.dart` generates a procedural mesh gradient (`_buildMeshGradient`) for every trip card instead of using the `cover_image_url` column that's already sitting in `supabase/schema.sql`. Cheap win: add an image-upload step to `create_trip_sheet.dart` and fall back to the gradient only when `cover_image_url == null`.

### 1.6 No "abstain" option in the UI despite the enum supporting it
`vote_value` includes `'abstain'`, but `proposal_card.dart`'s `_buildVoteButton` only offers Agree/Not for me. Either wire it in or drop it from the schema — right now it's dead capability.

---

## 2. 🎨 UI/UX & Micro-Interaction Enhancements

### 2.1 Every mutation flashes the entire screen back to a skeleton loader (real, reproducible)
`chat_screen.dart` correctly does this:
```dart
messagesState.when(
  skipLoadingOnReload: true,
  skipLoadingOnRefresh: true,
  ...
```
But **every other screen that mutates data doesn't** — `consensus_screen.dart`, `ledger_screen.dart`, `itinerary_screen.dart`, `members_screen.dart`, and `trips_dashboard_screen.dart` all call `.when()` without those flags. Since every controller calls `ref.invalidate(...)` after a mutation, Riverpod's `FutureProvider` briefly re-enters a loading state — and without `skipLoadingOnReload`, the whole list (including cards the user isn't even interacting with) unmounts and shows `AtlasSkeletonList()` for a beat. Concretely: casting a single vote makes the *entire proposals list* flicker to skeletons.

Fix (apply the same pattern everywhere `.when()` renders a data list), e.g. `atlas_app/lib/features/consensus/presentation/consensus_screen.dart`:
```dart
body: proposalsAsync.when(
  skipLoadingOnReload: true,
  skipLoadingOnRefresh: true,
  loading: () => const AtlasSkeletonList(),
  error: (err, _) => AtlasErrorState(...),
  data: (proposals) => ...,
),
```

### 2.2 Custom buttons lose native feedback and accessibility semantics
`AtlasCard`, `AppCard`, and the vote buttons in `proposal_card.dart` are built on raw `GestureDetector`, which gives no ripple, no focus ring, no built-in `Semantics(button: true)`. This is both a polish issue and an accessibility issue (TalkBack/VoiceOver won't announce these as buttons).

`atlas_app/lib/core/widgets/atlas_card.dart`:
```dart
if (onTap != null) {
  return Material(
    color: Colors.transparent,
    borderRadius: AppRadii.cardRadius,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardRadius,
      child: card,
    ),
  );
}
```

### 2.3 Contrast risk on muted/caption text
`AppColors.textMuted = 0xFF94A3B8` on `AppColors.card`/white gives roughly a 2.6:1 contrast ratio, below WCAG AA's 4.5:1 for body text. It's used for section headers (`atlas_section_header.dart`) and captions (`AppTextStyles.caption`) throughout. Recommend darkening to something closer to `0xFF6B7A90` or reserving `textMuted` strictly for decorative/disabled states, not for anything conveying information (e.g., date labels, timestamps).

### 2.4 Hero opportunity you're currently leaving on the table
Tapping a trip card in `trips_dashboard_screen.dart` navigates to `trip_overview_screen.dart`, which re-renders an entirely new gradient `SliverAppBar` background from scratch — there's a visible "pop" instead of a continuous transition. Wrap both gradient containers in a shared `Hero`:

```dart
// trips_dashboard_screen.dart
Hero(tag: 'trip-gradient-${trip['id']}', child: _buildMeshGradient(title))

// trip_overview_screen.dart
Hero(tag: 'trip-gradient-$tripId', child: Container(/* same gradient */))
```

### 2.5 Progressive-disclosure form UX gap
`create_trip_sheet.dart`'s step 2 lets the user tap "Create Trip" while `_dateRange == null && !_decideLater`, and only then shows an error snackbar (`_submit`). Prefer disabling the CTA until a valid state is reached — it's cheap and removes a dead-end tap:
```dart
AtlasButton(
  label: 'Create Trip',
  isLoading: tripState.isLoading,
  onPressed: (tripState.isLoading || (_dateRange == null && !_decideLater))
      ? null
      : _submit,
),
```

---

## 3. 🏗️ Architectural & Scalability Improvements

### 3.1 `appRouterProvider` rebuilds the *entire* GoRouter on every Supabase auth event — including silent token refresh
```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider).value; // <-- problem
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return GoRouter(...);
});
```
`authStateProvider` is a `StreamProvider` over `supabase.auth.onAuthStateChange`, which fires for `signedIn`, `signedOut`, `tokenRefreshed`, `userUpdated`, etc. Supabase refreshes JWTs automatically roughly every hour. Each of those emissions causes `appRouterProvider` to recompute and hand `MaterialApp.router` a **brand-new `GoRouter` instance**, which tears down and rebuilds the whole `Navigator` at `initialLocation`. In practice: a user three screens deep into a trip can get silently bounced back to the dashboard mid-session when their token refreshes.

Fix — decouple router *identity* from auth *state* using `refreshListenable`, and read auth inside `redirect` via `ref.read`, not `ref.watch`:

```dart
// atlas_app/lib/core/router/app_router.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final isAuthenticated = authRepository.currentUser != null; // ref.read equivalent
      final hasSeenOnboarding = sharedPrefs.getBool('has_seen_onboarding') ?? false;
      // ...same branching logic as before
      return null;
    },
    routes: [ /* unchanged */ ],
  );
});
```
This creates the `GoRouter` **once**; `refreshListenable` re-runs only the `redirect` callback (cheap) instead of replacing the whole router.

### 3.2 Real-time is a pillar in the pitch deck but only implemented for chat
`supabase/schema.sql` only enables realtime on one table:
```sql
alter publication supabase_realtime add table messages;
```
Votes, proposals, expenses, and itinerary events are all fetched via one-shot `FutureProvider`s and only refresh when *you* invalidate them after *your own* mutation. If your trip-mate votes on a proposal while you're looking at the Decisions tab, you won't see it until you background/foreground the app or pull-to-refresh. Given "Real-Time Collaboration" is Pillar 4 in your own PRD, I'd either convert `tripProposalsProvider`/`tripExpensesProvider` to `StreamProvider`s backed by `.stream()` (same pattern already proven in `chat_repository.dart`), or add a lightweight Supabase Realtime channel subscription that just calls `ref.invalidate(...)` on any change.

### 3.3 Row Level Security on `trip_members` is broader than it needs to be
```sql
CREATE POLICY "Users can view all trip members" ON public.trip_members FOR SELECT USING (true);
```
Any authenticated user can query the entire `trip_members` table and see which users belong to which trips — trip membership itself becomes public data across the whole app, not just to co-members. The comment says this is to avoid the classic RLS self-referential infinite-recursion problem, which is a real Postgres RLS pitfall, but the usual fix is a `SECURITY DEFINER` helper function instead of `USING (true)`:

```sql
CREATE OR REPLACE FUNCTION public.is_trip_member(_trip_id uuid, _user_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.trip_members
    WHERE trip_id = _trip_id AND user_id = _user_id
  );
$$;

DROP POLICY "Users can view all trip members" ON public.trip_members;
CREATE POLICY "Members can view their trip's roster" ON public.trip_members
  FOR SELECT USING (public.is_trip_member(trip_id, auth.uid()));
```
`SECURITY DEFINER` bypasses RLS *inside* the function body, breaking the recursive-policy problem without exposing the whole table.

### 3.4 No repository abstraction — every data layer class is a concrete Supabase wrapper
`TripRepository`, `MemberRepository`, `ExpenseRepository`, etc. are all directly instantiated concrete classes with no interface. This is fine at 6 features; at 50+ screens it means you can't unit-test controllers without a live/mocked Supabase client, and you can't swap persistence later without touching every call site. Introduce abstract interfaces per feature (`abstract class ITripRepository`) and have Riverpod providers return the interface type — this is a 30-minute refactor now, painful after 50 more screens are built against the concrete classes.

### 3.5 `createTrip` isn't atomic
`atlas_app/lib/features/trips/data/trip_repository.dart`:
```dart
final tripResponse = await _supabase.from('trips').insert({...}).select().single();
final tripId = tripResponse['id'];
await _supabase.from('trip_members').insert({'trip_id': tripId, 'user_id': userId, 'role': 'owner'});
```
Two round trips, no transaction. If the app is killed or the network drops between them, you get an orphaned trip with zero members that nobody (not even its creator) can ever see again under current RLS. Move this into a Postgres RPC:

```sql
CREATE OR REPLACE FUNCTION public.create_trip_with_owner(
  p_title text, p_description text, p_start_date date, p_end_date date
) RETURNS public.trips LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE new_trip public.trips;
BEGIN
  INSERT INTO public.trips (title, description, start_date, end_date, created_by)
  VALUES (p_title, p_description, p_start_date, p_end_date, auth.uid())
  RETURNING * INTO new_trip;

  INSERT INTO public.trip_members (trip_id, user_id, role)
  VALUES (new_trip.id, auth.uid(), 'owner');

  RETURN new_trip;
END; $$;
```
```dart
Future<void> createTrip({required String name, required String description, DateTime? startDate, DateTime? endDate}) async {
  if (_supabase.auth.currentUser == null) throw Exception('User must be logged in to create a trip');
  await _supabase.rpc('create_trip_with_owner', params: {
    'p_title': name,
    'p_description': description,
    'p_start_date': startDate?.toIso8601String(),
    'p_end_date': endDate?.toIso8601String(),
  });
}
```

---

## 4. 🐛 Critical Bugs & Edge Cases

### 4.1 🔴 "Needs your vote" on the trip Overview tab is permanently dead
`atlas_app/lib/features/trips/presentation/trip_overview_screen.dart`:
```dart
final openProposals = proposals.where((p) => p['status'] == 'open').toList();
```
The Postgres enum is `'pending' | 'approved' | 'rejected'` — `'open'` is never a value. This condition is always `false`, so this section always renders "All caught up," even when there are unresolved proposals. Fix:
```dart
final openProposals = proposals.where((p) => p['status'] == 'pending').toList();
```

### 4.2 🔴 "Remove from Trip" is completely non-functional
Three compounding bugs in the member-removal path:

**(a)** `member_repository.dart`'s `getTripMembers()` never selects the `trip_members.id` column:
```dart
.select('''
  role,
  joined_at,
  users ( id, full_name, avatar_url )
''')
```

**(b)** `members_screen.dart` calls it anyway:
```dart
await ref.read(memberControllerProvider.notifier).removeMember(member['id'], tripId);
```
`member['id']` is `null` here.

**(c)** Even if it weren't null, `removeMember(String tripId, String userId)`'s repository implementation filters on `user_id`, but the call above passes the *trip_members row id* (not a user id) as the first arg, and the actual trip id as the second — arguments are effectively transposed and the wrong id is used entirely:
```dart
Future<void> removeMember(String tripId, String userId) async {
  await _supabase.from('trip_members').delete().eq('trip_id', tripId).eq('user_id', userId);
}
```
Net effect: the delete query filters on garbage values and matches zero rows. The member is never removed, and depending on how errors surface, the user may see a false "success" or a confusing failure.

**Fix**, `atlas_app/lib/features/members/presentation/members_screen.dart`:
```dart
if (confirm) {
  try {
    final targetUserId = member['users']['id'] as String;
    await ref.read(memberControllerProvider.notifier).removeMember(tripId, targetUserId);
  } catch (e) {
    if (context.mounted) {
      AtlasSnackbar.error(context, 'Failed to remove: $e');
    }
  }
}
```
(The `id` selection fix in 4.2a is no longer strictly required once you use `member['users']['id']`, but add it back anyway — you'll want the row id for future edit-role functionality.)

### 4.3 🟠 Accepting an invitation doesn't refresh the trips dashboard
`atlas_app/lib/features/members/presentation/member_controller.dart`:
```dart
Future<void> acceptInvitation(String invitationId, String tripId, String role) async {
  state = const AsyncValue.loading();
  try {
    await _repo.acceptInvitation(invitationId, tripId, role);
    ref.invalidate(myInvitationsProvider);
    ref.invalidate(tripMembersProvider(tripId));
    state = const AsyncValue.data(null);
  } catch (e, st) { ... }
}
```
It never invalidates `userTripsProvider`. The user accepts an invite, it disappears from "Pending Invitations," but the trip won't appear under "Your Trips" until the next manual pull-to-refresh — a confusing "did that even work?" moment. Fix:
```dart
import '../../trips/presentation/trip_controller.dart'; // add

...
await _repo.acceptInvitation(invitationId, tripId, role);
ref.invalidate(myInvitationsProvider);
ref.invalidate(tripMembersProvider(tripId));
ref.invalidate(userTripsProvider); // add
state = const AsyncValue.data(null);
```

### 4.4 🟠 Failed chat messages fail silently and the typed text is lost
`atlas_app/lib/features/chat/presentation/chat_screen.dart`:
```dart
void _sendMessage() {
  final content = _messageController.text.trim();
  if (content.isEmpty) return;
  _messageController.clear();
  ref.read(chatControllerProvider.notifier).sendMessage(tripId: widget.tripId, content: content);
  _focusNode.requestFocus();
}
```
`ChatController.sendMessage` catches its own errors and sets `state = AsyncValue.error(...)` on `chatControllerProvider`, but nothing in `ChatScreen` listens to that provider. If the send fails (offline, RLS error, etc.), the text field has already been cleared and the user gets zero feedback — the message just vanishes. Fix, add to `build()` in `_ChatScreenState`:
```dart
@override
Widget build(BuildContext context) {
  ref.listen<AsyncValue>(chatControllerProvider, (previous, next) {
    if (next.hasError) {
      AtlasSnackbar.error(context, 'Message failed to send. Check your connection.');
    }
  });
  // ...rest of build unchanged
}
```

### 4.5 🟡 `users.email` is referenced in UI but never stored/selected
`atlas_app/lib/features/members/presentation/members_screen.dart`:
```dart
if (user != null && user['email'] != null) ...[
  Text(user['email'], style: AppTextStyles.secondary),
],
```
`public.users` (per `supabase/schema.sql`) has no `email` column — only `auth.users` does, which isn't joinable client-side under RLS. This branch is permanently dead code, silently. If you want emails visible in the member roster, either add `email` to `public.users` (populate it in the `handle_new_user()` trigger) or expose it via a `SECURITY DEFINER` view scoped to trip co-members.

### 4.6 🟡 Router redirect double-checked
Confirmed working correctly in isolation (`app_router.dart`'s `redirect` logic properly branches unauthenticated → onboarding/login vs. authenticated → away from those routes), but it's undermined entirely by 3.1 above — the logic is fine, the *lifecycle* wrapping it is the problem.

---

**If I had to pick three things to fix before any public beta:** 4.2 (member removal is silently broken), 4.1 + 1.1 together (consensus voting never resolves — this is your core pitch), and 3.1 (router resets sessions on token refresh, which will look like random app instability to real users).