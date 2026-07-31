// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get username; String get display_name; String get email; String get role; String get status; String? get profile_picture; String? get department; int? get year; String? get section; String get bio; int get friends_count; int get asks_count; int get helps_count;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.profile_picture, profile_picture) || other.profile_picture == profile_picture)&&(identical(other.department, department) || other.department == department)&&(identical(other.year, year) || other.year == year)&&(identical(other.section, section) || other.section == section)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.friends_count, friends_count) || other.friends_count == friends_count)&&(identical(other.asks_count, asks_count) || other.asks_count == asks_count)&&(identical(other.helps_count, helps_count) || other.helps_count == helps_count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,display_name,email,role,status,profile_picture,department,year,section,bio,friends_count,asks_count,helps_count);

@override
String toString() {
  return 'User(id: $id, username: $username, display_name: $display_name, email: $email, role: $role, status: $status, profile_picture: $profile_picture, department: $department, year: $year, section: $section, bio: $bio, friends_count: $friends_count, asks_count: $asks_count, helps_count: $helps_count)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String username, String display_name, String email, String role, String status, String? profile_picture, String? department, int? year, String? section, String bio, int friends_count, int asks_count, int helps_count
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? display_name = null,Object? email = null,Object? role = null,Object? status = null,Object? profile_picture = freezed,Object? department = freezed,Object? year = freezed,Object? section = freezed,Object? bio = null,Object? friends_count = null,Object? asks_count = null,Object? helps_count = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,profile_picture: freezed == profile_picture ? _self.profile_picture : profile_picture // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,friends_count: null == friends_count ? _self.friends_count : friends_count // ignore: cast_nullable_to_non_nullable
as int,asks_count: null == asks_count ? _self.asks_count : asks_count // ignore: cast_nullable_to_non_nullable
as int,helps_count: null == helps_count ? _self.helps_count : helps_count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String display_name,  String email,  String role,  String status,  String? profile_picture,  String? department,  int? year,  String? section,  String bio,  int friends_count,  int asks_count,  int helps_count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.display_name,_that.email,_that.role,_that.status,_that.profile_picture,_that.department,_that.year,_that.section,_that.bio,_that.friends_count,_that.asks_count,_that.helps_count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String display_name,  String email,  String role,  String status,  String? profile_picture,  String? department,  int? year,  String? section,  String bio,  int friends_count,  int asks_count,  int helps_count)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.username,_that.display_name,_that.email,_that.role,_that.status,_that.profile_picture,_that.department,_that.year,_that.section,_that.bio,_that.friends_count,_that.asks_count,_that.helps_count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String display_name,  String email,  String role,  String status,  String? profile_picture,  String? department,  int? year,  String? section,  String bio,  int friends_count,  int asks_count,  int helps_count)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.display_name,_that.email,_that.role,_that.status,_that.profile_picture,_that.department,_that.year,_that.section,_that.bio,_that.friends_count,_that.asks_count,_that.helps_count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.username, required this.display_name, required this.email, required this.role, required this.status, this.profile_picture, this.department, this.year, this.section, this.bio = "", this.friends_count = 0, this.asks_count = 0, this.helps_count = 0});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String username;
@override final  String display_name;
@override final  String email;
@override final  String role;
@override final  String status;
@override final  String? profile_picture;
@override final  String? department;
@override final  int? year;
@override final  String? section;
@override@JsonKey() final  String bio;
@override@JsonKey() final  int friends_count;
@override@JsonKey() final  int asks_count;
@override@JsonKey() final  int helps_count;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.profile_picture, profile_picture) || other.profile_picture == profile_picture)&&(identical(other.department, department) || other.department == department)&&(identical(other.year, year) || other.year == year)&&(identical(other.section, section) || other.section == section)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.friends_count, friends_count) || other.friends_count == friends_count)&&(identical(other.asks_count, asks_count) || other.asks_count == asks_count)&&(identical(other.helps_count, helps_count) || other.helps_count == helps_count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,display_name,email,role,status,profile_picture,department,year,section,bio,friends_count,asks_count,helps_count);

@override
String toString() {
  return 'User(id: $id, username: $username, display_name: $display_name, email: $email, role: $role, status: $status, profile_picture: $profile_picture, department: $department, year: $year, section: $section, bio: $bio, friends_count: $friends_count, asks_count: $asks_count, helps_count: $helps_count)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String display_name, String email, String role, String status, String? profile_picture, String? department, int? year, String? section, String bio, int friends_count, int asks_count, int helps_count
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? display_name = null,Object? email = null,Object? role = null,Object? status = null,Object? profile_picture = freezed,Object? department = freezed,Object? year = freezed,Object? section = freezed,Object? bio = null,Object? friends_count = null,Object? asks_count = null,Object? helps_count = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,profile_picture: freezed == profile_picture ? _self.profile_picture : profile_picture // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,friends_count: null == friends_count ? _self.friends_count : friends_count // ignore: cast_nullable_to_non_nullable
as int,asks_count: null == asks_count ? _self.asks_count : asks_count // ignore: cast_nullable_to_non_nullable
as int,helps_count: null == helps_count ? _self.helps_count : helps_count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AuthToken {

 String get access_token; String get token_type; String get refresh_token;
/// Create a copy of AuthToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokenCopyWith<AuthToken> get copyWith => _$AuthTokenCopyWithImpl<AuthToken>(this as AuthToken, _$identity);

  /// Serializes this AuthToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthToken&&(identical(other.access_token, access_token) || other.access_token == access_token)&&(identical(other.token_type, token_type) || other.token_type == token_type)&&(identical(other.refresh_token, refresh_token) || other.refresh_token == refresh_token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access_token,token_type,refresh_token);

@override
String toString() {
  return 'AuthToken(access_token: $access_token, token_type: $token_type, refresh_token: $refresh_token)';
}


}

/// @nodoc
abstract mixin class $AuthTokenCopyWith<$Res>  {
  factory $AuthTokenCopyWith(AuthToken value, $Res Function(AuthToken) _then) = _$AuthTokenCopyWithImpl;
@useResult
$Res call({
 String access_token, String token_type, String refresh_token
});




}
/// @nodoc
class _$AuthTokenCopyWithImpl<$Res>
    implements $AuthTokenCopyWith<$Res> {
  _$AuthTokenCopyWithImpl(this._self, this._then);

  final AuthToken _self;
  final $Res Function(AuthToken) _then;

/// Create a copy of AuthToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? access_token = null,Object? token_type = null,Object? refresh_token = null,}) {
  return _then(_self.copyWith(
access_token: null == access_token ? _self.access_token : access_token // ignore: cast_nullable_to_non_nullable
as String,token_type: null == token_type ? _self.token_type : token_type // ignore: cast_nullable_to_non_nullable
as String,refresh_token: null == refresh_token ? _self.refresh_token : refresh_token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthToken].
extension AuthTokenPatterns on AuthToken {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthToken() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthToken value)  $default,){
final _that = this;
switch (_that) {
case _AuthToken():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthToken value)?  $default,){
final _that = this;
switch (_that) {
case _AuthToken() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String access_token,  String token_type,  String refresh_token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthToken() when $default != null:
return $default(_that.access_token,_that.token_type,_that.refresh_token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String access_token,  String token_type,  String refresh_token)  $default,) {final _that = this;
switch (_that) {
case _AuthToken():
return $default(_that.access_token,_that.token_type,_that.refresh_token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String access_token,  String token_type,  String refresh_token)?  $default,) {final _that = this;
switch (_that) {
case _AuthToken() when $default != null:
return $default(_that.access_token,_that.token_type,_that.refresh_token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthToken implements AuthToken {
  const _AuthToken({required this.access_token, required this.token_type, required this.refresh_token});
  factory _AuthToken.fromJson(Map<String, dynamic> json) => _$AuthTokenFromJson(json);

@override final  String access_token;
@override final  String token_type;
@override final  String refresh_token;

/// Create a copy of AuthToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokenCopyWith<_AuthToken> get copyWith => __$AuthTokenCopyWithImpl<_AuthToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthTokenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthToken&&(identical(other.access_token, access_token) || other.access_token == access_token)&&(identical(other.token_type, token_type) || other.token_type == token_type)&&(identical(other.refresh_token, refresh_token) || other.refresh_token == refresh_token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access_token,token_type,refresh_token);

@override
String toString() {
  return 'AuthToken(access_token: $access_token, token_type: $token_type, refresh_token: $refresh_token)';
}


}

/// @nodoc
abstract mixin class _$AuthTokenCopyWith<$Res> implements $AuthTokenCopyWith<$Res> {
  factory _$AuthTokenCopyWith(_AuthToken value, $Res Function(_AuthToken) _then) = __$AuthTokenCopyWithImpl;
@override @useResult
$Res call({
 String access_token, String token_type, String refresh_token
});




}
/// @nodoc
class __$AuthTokenCopyWithImpl<$Res>
    implements _$AuthTokenCopyWith<$Res> {
  __$AuthTokenCopyWithImpl(this._self, this._then);

  final _AuthToken _self;
  final $Res Function(_AuthToken) _then;

/// Create a copy of AuthToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? access_token = null,Object? token_type = null,Object? refresh_token = null,}) {
  return _then(_AuthToken(
access_token: null == access_token ? _self.access_token : access_token // ignore: cast_nullable_to_non_nullable
as String,token_type: null == token_type ? _self.token_type : token_type // ignore: cast_nullable_to_non_nullable
as String,refresh_token: null == refresh_token ? _self.refresh_token : refresh_token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
