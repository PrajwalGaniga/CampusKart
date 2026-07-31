import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotification>>>((ref) {
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider));
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRepository _repository;

  NotificationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      if (state.hasValue) {
        final notifications = state.value!.map((n) {
          if (n.id == notificationId.toString()) {
            return n.copyWith(is_read: true);
          }
          return n;
        }).toList();
        state = AsyncValue.data(notifications);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (state.hasValue) {
        final notifications = state.value!.map((n) => n.copyWith(is_read: true)).toList();
        state = AsyncValue.data(notifications);
      }
    } catch (e) {
      rethrow;
    }
  }
}
