// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSearchResponse _$UserSearchResponseFromJson(Map<String, dynamic> json) =>
    _UserSearchResponse(
      id: json['id'] as String,
      username: json['username'] as String,
      display_name: json['display_name'] as String,
      profile_image: json['profile_image'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$UserSearchResponseToJson(_UserSearchResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.display_name,
      'profile_image': instance.profile_image,
      'status': instance.status,
    };

_PendingRequestResponse _$PendingRequestResponseFromJson(
  Map<String, dynamic> json,
) => _PendingRequestResponse(
  request_id: json['request_id'] as String,
  username: json['username'] as String,
  display_name: json['display_name'] as String,
  profile_image: json['profile_image'] as String,
  created_at: json['created_at'] as String,
);

Map<String, dynamic> _$PendingRequestResponseToJson(
  _PendingRequestResponse instance,
) => <String, dynamic>{
  'request_id': instance.request_id,
  'username': instance.username,
  'display_name': instance.display_name,
  'profile_image': instance.profile_image,
  'created_at': instance.created_at,
};

_FriendResponse _$FriendResponseFromJson(Map<String, dynamic> json) =>
    _FriendResponse(
      id: json['id'] as String,
      username: json['username'] as String,
      display_name: json['display_name'] as String,
      status: json['status'] as String,
      friends_since: json['friends_since'] as String,
    );

Map<String, dynamic> _$FriendResponseToJson(_FriendResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.display_name,
      'status': instance.status,
      'friends_since': instance.friends_since,
    };
