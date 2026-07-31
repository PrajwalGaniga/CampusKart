// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  username: json['username'] as String,
  display_name: json['display_name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  status: json['status'] as String,
  profile_picture: json['profile_picture'] as String?,
  department: json['department'] as String?,
  year: (json['year'] as num?)?.toInt(),
  section: json['section'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'display_name': instance.display_name,
  'email': instance.email,
  'role': instance.role,
  'status': instance.status,
  'profile_picture': instance.profile_picture,
  'department': instance.department,
  'year': instance.year,
  'section': instance.section,
};

_AuthToken _$AuthTokenFromJson(Map<String, dynamic> json) => _AuthToken(
  access_token: json['access_token'] as String,
  token_type: json['token_type'] as String,
  refresh_token: json['refresh_token'] as String,
);

Map<String, dynamic> _$AuthTokenToJson(_AuthToken instance) =>
    <String, dynamic>{
      'access_token': instance.access_token,
      'token_type': instance.token_type,
      'refresh_token': instance.refresh_token,
    };
