import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';

final notificationsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.notificationsStream;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider).value ?? [];
  return notifications.where((n) => n['is_read'] == false).length;
});

class NotificationController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
  }
}

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref.watch(notificationRepositoryProvider));
});
