import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorFormatter {
  static String format(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      
      if (message.contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }
      if (message.contains('user already registered')) {
        return 'An account with this email already exists.';
      }
      if (message.contains('password should be at least')) {
        return 'Password is too weak. Please use at least 6 characters.';
      }
      if (message.contains('email link')) {
        return 'Invalid or expired email link.';
      }
      return error.message; // Fallback to the original message if not specifically handled
    }
    
    // For other types of errors
    return 'An unexpected error occurred. Please try again.';
  }
}
