import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorHandler {
  /// Converts raw exceptions into friendly human sentences.
  static String getErrorMessage(Object e) {
    if (e is PostgrestException) {
      if (e.code == '23505') {
        // Unique violation
        if (e.message.contains('trip_members')) {
          return 'You are already a member of this trip!';
        }
        return 'This item already exists.';
      }
      if (e.code == 'PGRST301') {
        return 'You do not have permission to access this data.';
      }
      return 'A database error occurred: ${e.message}';
    } 
    
    if (e is AuthException) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }
      if (e.message.toLowerCase().contains('email not confirmed')) {
        return 'Please verify your email address before logging in.';
      }
      if (e.message.toLowerCase().contains('user already registered')) {
        return 'An account with this email already exists.';
      }
      return e.message; // AuthException messages are usually somewhat friendly
    }

    // Default generic error fallback
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    return msg;
  }
}
