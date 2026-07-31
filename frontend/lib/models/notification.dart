import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

// ignore_for_file: non_constant_identifier_names
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String user_id,
    required String title,
    required String message,
    required String type,
    @Default('') String sender_avatar,
    required bool is_read,
    required DateTime created_at,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}
