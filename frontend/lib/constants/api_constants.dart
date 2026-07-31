import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static String get wsUrl {
    if (kIsWeb) return 'ws://127.0.0.1:8000/ws/private';
    if (defaultTargetPlatform == TargetPlatform.android) return 'ws://10.0.2.2:8000/ws/private';
    return 'ws://127.0.0.1:8000/ws/private';
  }

  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String me = '/api/v1/users/me';
  static const String changePassword = '/api/v1/users/change-password';

  static const String asksFeed = '/api/v1/asks/feed';
  static const String asksMy = '/api/v1/asks/my';
  static const String asks = '/api/v1/asks/';

  static String askReplies(String id) => '/api/v1/asks/$id/replies';
  static String askReply(String id) => '/api/v1/asks/$id/reply';
  static String askResolve(String id) => '/api/v1/asks/$id/resolve';

  static const String friends = '/api/v1/friends/';
  static const String friendRequests = '/api/v1/friends/request';
  static const String pendingRequests = '/api/v1/friends/pending';
  static const String searchUsers = '/api/v1/friends/search';

  static const String acceptRequest = '/api/v1/friends/accept';
  static const String rejectRequest = '/api/v1/friends/reject';
  static const String cancelRequest = '/api/v1/friends/cancel';
  static String removeFriend(String id) => '/api/v1/friends/$id';

  static const String notifications = '/api/v1/notifications/';
  static String markNotificationRead(String id) => '/api/v1/notifications/$id/read';
  static const String markAllNotificationsRead = '/api/v1/notifications/read-all';
}
