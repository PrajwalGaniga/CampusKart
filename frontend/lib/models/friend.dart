import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend.freezed.dart';
part 'friend.g.dart';

@freezed
abstract class UserSearchResponse with _$UserSearchResponse {
  const factory UserSearchResponse({
    required String id,
    required String username,
    required String display_name,
    required String profile_image,
    required String status,
    @Default('NONE') String friendship_status,
  }) = _UserSearchResponse;

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) => _$UserSearchResponseFromJson(json);
}

@freezed
abstract class PendingRequestResponse with _$PendingRequestResponse {
  const factory PendingRequestResponse({
    required String request_id,
    required String username,
    required String display_name,
    required String profile_image,
    required String created_at,
  }) = _PendingRequestResponse;

  factory PendingRequestResponse.fromJson(Map<String, dynamic> json) => _$PendingRequestResponseFromJson(json);
}

@freezed
abstract class FriendResponse with _$FriendResponse {
  const factory FriendResponse({
    required String id,
    required String username,
    required String display_name,
    required String status,
    required String friends_since,
  }) = _FriendResponse;

  factory FriendResponse.fromJson(Map<String, dynamic> json) => _$FriendResponseFromJson(json);
}
