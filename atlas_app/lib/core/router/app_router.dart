import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart'; // For sharedPreferencesProvider
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/trips/presentation/trips_dashboard_screen.dart';
import '../../features/trips/presentation/trip_details_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/members/presentation/members_screen.dart';

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
      final isAuthenticated = authRepository.currentUser != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      
      final hasSeenOnboarding = sharedPrefs.getBool('has_seen_onboarding') ?? false;

      // Unauthenticated flows
      if (!isAuthenticated) {
        if (!hasSeenOnboarding && !isGoingToOnboarding) {
          return '/onboarding';
        }
        if (hasSeenOnboarding && !isGoingToLogin && !isGoingToSignup && !isGoingToOnboarding) {
          return '/login';
        }
      }

      // Authenticated flows
      if (isAuthenticated) {
        if (isGoingToLogin || isGoingToSignup || isGoingToOnboarding) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TripsDashboardScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/trip/:id',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          final tab = state.uri.queryParameters['tab'];
          int initialIndex = 0;
          if (tab == 'itinerary') initialIndex = 1;
          if (tab == 'ledger') initialIndex = 2;
          if (tab == 'chat') initialIndex = 4; // Chat is actually index 4
          return TripDetailsScreen(tripId: tripId, initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/trip/:id/members',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return MembersScreen(tripId: tripId);
        },
      ),
    ],
  );
});
