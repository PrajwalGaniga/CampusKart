import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/notification.dart';
import '../services/dio_client.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    return (response.data as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.patch(ApiConstants.markNotificationRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await _dio.post(ApiConstants.markAllNotificationsRead);
  }
}
