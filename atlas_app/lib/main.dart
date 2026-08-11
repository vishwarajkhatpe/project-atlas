import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

Future<void> _setHighRefreshRate() async {
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Ignore on unsupported platforms (e.g., iOS handles ProMotion via Info.plist)
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _setHighRefreshRate();
    
    // Enable edge-to-edge UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Initialize SharedPreferences
    final sharedPrefs = await SharedPreferences.getInstance();

    // Read keys from --dart-define-from-file
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Missing Supabase configuration.\nPlease run with --dart-define-from-file=.env',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    } catch (e) {
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Failed to initialize Supabase:\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
      return;
    }

    // Set up crash reporting (placeholder for Firebase/Sentry)
    FlutterError.onError = (details) {
      debugPrint('FlutterError caught: ${details.exception}');
    };

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const AtlasApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught exception in runZonedGuarded: $error\n$stack');
  });
}

class AtlasApp extends ConsumerWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Atlas: Group Travel & Expenses',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
