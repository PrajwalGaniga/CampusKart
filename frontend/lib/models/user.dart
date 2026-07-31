import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

// ignore_for_file: non_constant_identifier_names
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String display_name,
    required String email,
    required String role,
    required String status,
    String? profile_picture,
    String? department,
    int? year,
    String? section,
    @Default("") String bio,
    @Default(0) int friends_count,
    @Default(0) int asks_count,
    @Default(0) int helps_count,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String access_token,
    required String token_type,
    required String refresh_token,
  }) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) => _$AuthTokenFromJson(json);
}
