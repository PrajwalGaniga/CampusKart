import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    return 'https://dawdlingly-pseudoinsane-pa.ngrok-free.dev';
  }

  static String get wsUrl {
    return 'wss://dawdlingly-pseudoinsane-pa.ngrok-free.dev/ws/private';
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
  static String deleteAsk(String id) => '/api/v1/asks/$id';

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
