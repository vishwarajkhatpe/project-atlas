import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';

// StreamProvider automatically listens to the stream and exposes the latest value
final tripMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessagesStream(tripId);
});

final chatControllerProvider = AsyncNotifierProvider<ChatController, void>(() {
  return ChatController();
});

class ChatController extends AsyncNotifier<void> {
  late final ChatRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(chatRepositoryProvider);
    return null;
  }

  Future<void> sendMessage({
    required String tripId,
    required String content,
  }) async {
    // We don't set state to loading for sending a message because it should feel instant
    // and we don't want to block the UI. StreamProvider will automatically update.
    try {
      await _repo.sendMessage(
        tripId: tripId,
        content: content,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> deleteMessage(dynamic messageId) async {
    try {
      await _repo.deleteMessage(messageId);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
