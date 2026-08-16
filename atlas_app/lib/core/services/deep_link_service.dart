import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/trips/data/trip_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../main.dart'; // For sharedPreferencesProvider
import '../utils/app_error_handler.dart';
import '../widgets/atlas_snackbar.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService(ref);
});

class DeepLinkService {
  final Ref _ref;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this._ref) {
    _appLinks = AppLinks();
  }

  void init(BuildContext context) {
    // Handle app opened from terminated state
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null && context.mounted) {
        _handleDeepLink(uri, context);
      }
    });

    // Handle app opened from background state
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (context.mounted) {
        _handleDeepLink(uri, context);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  Future<void> _handleDeepLink(Uri uri, BuildContext context) async {
    debugPrint('Received deep link: $uri');
    
    // Check if the link is for joining a trip
    if (uri.scheme == 'atlas' && uri.host == 'join') {
      final tripId = uri.queryParameters['tripId'];
      if (tripId != null && tripId.isNotEmpty) {
        if (!context.mounted) return;
        
        // Check if user is authenticated
        final authRepo = _ref.read(authRepositoryProvider);
        if (authRepo.currentUser == null) {
          // Unauthenticated! Save the pending trip invite to SharedPreferences
          final prefs = _ref.read(sharedPreferencesProvider);
          await prefs.setString('pending_trip_invite_id', tripId);
          
          if (context.mounted) {
            AtlasSnackbar.success(context, 'Please sign in or sign up to join the trip.');
            // GoRouter will naturally handle pushing to /login or /signup, but we can explicitly go to /signup 
            context.go('/signup');
          }
          return;
        }

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );

        try {
          await _ref.read(tripRepositoryProvider).joinTrip(tripId);
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // Close loading
            AtlasSnackbar.success(context, 'Successfully joined the trip!');
            // Navigate to the trip details
            context.go('/trip/$tripId');
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // Close loading
            final errorMsg = AppErrorHandler.getErrorMessage(e);
            AtlasSnackbar.error(context, errorMsg);
            
            // Still navigate to the trip if they were already a member
            if (errorMsg.toLowerCase().contains('already a member')) {
              context.go('/trip/$tripId');
            }
          }
        }
      }
    }
  }
}
