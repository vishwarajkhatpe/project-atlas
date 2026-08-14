import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/trips/data/trip_repository.dart';
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
            String errorMsg = e.toString();
            if (errorMsg.contains('Trip not found')) {
              errorMsg = 'Invalid or expired invite code.';
            } else if (errorMsg.contains('Already a member')) {
              errorMsg = 'You are already a member of this trip.';
            } else if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            AtlasSnackbar.error(context, errorMsg);
          }
        }
      }
    }
  }
}
