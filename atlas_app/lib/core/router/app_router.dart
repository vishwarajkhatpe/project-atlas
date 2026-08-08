import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/trips/presentation/trips_dashboard_screen.dart';
import '../../features/trips/presentation/trip_details_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider).value;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState?.session != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';

      if (!isAuthenticated && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }

      if (isAuthenticated && (isGoingToLogin || isGoingToSignup)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TripsDashboardScreen(),
      ),
      GoRoute(
        path: '/trip/:id',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return TripDetailsScreen(tripId: tripId);
        },
      ),
    ],
  );
});
