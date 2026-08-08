import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository(this._supabase);

  // Get a real-time stream of messages for a trip
  Stream<List<Map<String, dynamic>>> getMessagesStream(String tripId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: false) // Fetch newest first for chat UI
        .map((maps) {
          // We need to fetch user details for each message, but .stream() doesn't support joins natively.
          // However, since we just need the user's name, we will fetch it in a separate step in the controller,
          // or we can use a database view.
          // For simplicity in MVP, we just return the raw messages.
          return maps;
        });
  }

  // Send a new message
  Future<void> sendMessage({
    required String tripId,
    required String content,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    await _supabase.from('messages').insert({
      'trip_id': tripId,
      'user_id': userId,
      'content': content,
    });
  }
}
