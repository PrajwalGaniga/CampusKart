class ApiConstants {
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator / web
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String wsUrl = 'ws://10.0.2.2:8000/ws/private';

  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String me = '/api/v1/users/me';
  static const String changePassword = '/api/v1/users/change-password';

  static const String asksFeed = '/api/v1/asks/feed';
  static const String asks = '/api/v1/asks/';

  static String askReplies(int id) => '/api/v1/asks/$id/replies';
  static String askReply(int id) => '/api/v1/asks/$id/reply';
  static String askResolve(int id) => '/api/v1/asks/$id/resolve';

  static const String friends = '/api/v1/friends/';
  static const String friendRequests = '/api/v1/friends/requests';
  static const String pendingRequests = '/api/v1/friends/requests/pending';
  static const String searchUsers = '/api/v1/friends/search';

  static String acceptRequest(int id) => '/api/v1/friends/requests/$id/accept';
  static String rejectRequest(int id) => '/api/v1/friends/requests/$id/reject';
  static String cancelRequest(int id) => '/api/v1/friends/requests/$id/cancel';
  static String removeFriend(int id) => '/api/v1/friends/$id';

  static const String notifications = '/api/v1/notifications/';
  static String markNotificationRead(int id) => '/api/v1/notifications/$id/read';
  static const String markAllNotificationsRead = '/api/v1/notifications/read-all';
}
