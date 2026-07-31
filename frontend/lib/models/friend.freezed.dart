// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSearchResponse {

 String get id; String get username; String get display_name; String get profile_image; String get status; String get friendship_status;
/// Create a copy of UserSearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSearchResponseCopyWith<UserSearchResponse> get copyWith => _$UserSearchResponseCopyWithImpl<UserSearchResponse>(this as UserSearchResponse, _$identity);

  /// Serializes this UserSearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSearchResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.profile_image, profile_image) || other.profile_image == profile_image)&&(identical(other.status, status) || other.status == status)&&(identical(other.friendship_status, friendship_status) || other.friendship_status == friendship_status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,display_name,profile_image,status,friendship_status);

@override
String toString() {
  return 'UserSearchResponse(id: $id, username: $username, display_name: $display_name, profile_image: $profile_image, status: $status, friendship_status: $friendship_status)';
}


}

/// @nodoc
abstract mixin class $UserSearchResponseCopyWith<$Res>  {
  factory $UserSearchResponseCopyWith(UserSearchResponse value, $Res Function(UserSearchResponse) _then) = _$UserSearchResponseCopyWithImpl;
@useResult
$Res call({
 String id, String username, String display_name, String profile_image, String status, String friendship_status
});




}
/// @nodoc
class _$UserSearchResponseCopyWithImpl<$Res>
    implements $UserSearchResponseCopyWith<$Res> {
  _$UserSearchResponseCopyWithImpl(this._self, this._then);

  final UserSearchResponse _self;
  final $Res Function(UserSearchResponse) _then;

/// Create a copy of UserSearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? display_name = null,Object? profile_image = null,Object? status = null,Object? friendship_status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,profile_image: null == profile_image ? _self.profile_image : profile_image // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,friendship_status: null == friendship_status ? _self.friendship_status : friendship_status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSearchResponse].
extension UserSearchResponsePatterns on UserSearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserSearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserSearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String display_name,  String profile_image,  String status,  String friendship_status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSearchResponse() when $default != null:
return $default(_that.id,_that.username,_that.display_name,_that.profile_image,_that.status,_that.friendship_status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String display_name,  String profile_image,  String status,  String friendship_status)  $default,) {final _that = this;
switch (_that) {
case _UserSearchResponse():
return $default(_that.id,_that.username,_that.display_name,_that.profile_image,_that.status,_that.friendship_status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String display_name,  String profile_image,  String status,  String friendship_status)?  $default,) {final _that = this;
switch (_that) {
case _UserSearchResponse() when $default != null:
return $default(_that.id,_that.username,_that.display_name,_that.profile_image,_that.status,_that.friendship_status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSearchResponse implements UserSearchResponse {
  const _UserSearchResponse({required this.id, required this.username, required this.display_name, required this.profile_image, required this.status, this.friendship_status = 'NONE'});
  factory _UserSearchResponse.fromJson(Map<String, dynamic> json) => _$UserSearchResponseFromJson(json);

@override final  String id;
@override final  String username;
@override final  String display_name;
@override final  String profile_image;
@override final  String status;
@override@JsonKey() final  String friendship_status;

/// Create a copy of UserSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSearchResponseCopyWith<_UserSearchResponse> get copyWith => __$UserSearchResponseCopyWithImpl<_UserSearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSearchResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.profile_image, profile_image) || other.profile_image == profile_image)&&(identical(other.status, status) || other.status == status)&&(identical(other.friendship_status, friendship_status) || other.friendship_status == friendship_status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,display_name,profile_image,status,friendship_status);

@override
String toString() {
  return 'UserSearchResponse(id: $id, username: $username, display_name: $display_name, profile_image: $profile_image, status: $status, friendship_status: $friendship_status)';
}


}

/// @nodoc
abstract mixin class _$UserSearchResponseCopyWith<$Res> implements $UserSearchResponseCopyWith<$Res> {
  factory _$UserSearchResponseCopyWith(_UserSearchResponse value, $Res Function(_UserSearchResponse) _then) = __$UserSearchResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String display_name, String profile_image, String status, String friendship_status
});




}
/// @nodoc
class __$UserSearchResponseCopyWithImpl<$Res>
    implements _$UserSearchResponseCopyWith<$Res> {
  __$UserSearchResponseCopyWithImpl(this._self, this._then);

  final _UserSearchResponse _self;
  final $Res Function(_UserSearchResponse) _then;

/// Create a copy of UserSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? display_name = null,Object? profile_image = null,Object? status = null,Object? friendship_status = null,}) {
  return _then(_UserSearchResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,profile_image: null == profile_image ? _self.profile_image : profile_image // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,friendship_status: null == friendship_status ? _self.friendship_status : friendship_status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PendingRequestResponse {

 String get request_id; String get username; String get display_name; String get profile_image; String get created_at;
/// Create a copy of PendingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingRequestResponseCopyWith<PendingRequestResponse> get copyWith => _$PendingRequestResponseCopyWithImpl<PendingRequestResponse>(this as PendingRequestResponse, _$identity);

  /// Serializes this PendingRequestResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingRequestResponse&&(identical(other.request_id, request_id) || other.request_id == request_id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.profile_image, profile_image) || other.profile_image == profile_image)&&(identical(other.created_at, created_at) || other.created_at == created_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,request_id,username,display_name,profile_image,created_at);

@override
String toString() {
  return 'PendingRequestResponse(request_id: $request_id, username: $username, display_name: $display_name, profile_image: $profile_image, created_at: $created_at)';
}


}

/// @nodoc
abstract mixin class $PendingRequestResponseCopyWith<$Res>  {
  factory $PendingRequestResponseCopyWith(PendingRequestResponse value, $Res Function(PendingRequestResponse) _then) = _$PendingRequestResponseCopyWithImpl;
@useResult
$Res call({
 String request_id, String username, String display_name, String profile_image, String created_at
});




}
/// @nodoc
class _$PendingRequestResponseCopyWithImpl<$Res>
    implements $PendingRequestResponseCopyWith<$Res> {
  _$PendingRequestResponseCopyWithImpl(this._self, this._then);

  final PendingRequestResponse _self;
  final $Res Function(PendingRequestResponse) _then;

/// Create a copy of PendingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request_id = null,Object? username = null,Object? display_name = null,Object? profile_image = null,Object? created_at = null,}) {
  return _then(_self.copyWith(
request_id: null == request_id ? _self.request_id : request_id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,profile_image: null == profile_image ? _self.profile_image : profile_image // ignore: cast_nullable_to_non_nullable
as String,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingRequestResponse].
extension PendingRequestResponsePatterns on PendingRequestResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingRequestResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingRequestResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingRequestResponse value)  $default,){
final _that = this;
switch (_that) {
case _PendingRequestResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingRequestResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PendingRequestResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String request_id,  String username,  String display_name,  String profile_image,  String created_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingRequestResponse() when $default != null:
return $default(_that.request_id,_that.username,_that.display_name,_that.profile_image,_that.created_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String request_id,  String username,  String display_name,  String profile_image,  String created_at)  $default,) {final _that = this;
switch (_that) {
case _PendingRequestResponse():
return $default(_that.request_id,_that.username,_that.display_name,_that.profile_image,_that.created_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String request_id,  String username,  String display_name,  String profile_image,  String created_at)?  $default,) {final _that = this;
switch (_that) {
case _PendingRequestResponse() when $default != null:
return $default(_that.request_id,_that.username,_that.display_name,_that.profile_image,_that.created_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingRequestResponse implements PendingRequestResponse {
  const _PendingRequestResponse({required this.request_id, required this.username, required this.display_name, required this.profile_image, required this.created_at});
  factory _PendingRequestResponse.fromJson(Map<String, dynamic> json) => _$PendingRequestResponseFromJson(json);

@override final  String request_id;
@override final  String username;
@override final  String display_name;
@override final  String profile_image;
@override final  String created_at;

/// Create a copy of PendingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingRequestResponseCopyWith<_PendingRequestResponse> get copyWith => __$PendingRequestResponseCopyWithImpl<_PendingRequestResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingRequestResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingRequestResponse&&(identical(other.request_id, request_id) || other.request_id == request_id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.profile_image, profile_image) || other.profile_image == profile_image)&&(identical(other.created_at, created_at) || other.created_at == created_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,request_id,username,display_name,profile_image,created_at);

@override
String toString() {
  return 'PendingRequestResponse(request_id: $request_id, username: $username, display_name: $display_name, profile_image: $profile_image, created_at: $created_at)';
}


}

/// @nodoc
abstract mixin class _$PendingRequestResponseCopyWith<$Res> implements $PendingRequestResponseCopyWith<$Res> {
  factory _$PendingRequestResponseCopyWith(_PendingRequestResponse value, $Res Function(_PendingRequestResponse) _then) = __$PendingRequestResponseCopyWithImpl;
@override @useResult
$Res call({
 String request_id, String username, String display_name, String profile_image, String created_at
});




}
/// @nodoc
class __$PendingRequestResponseCopyWithImpl<$Res>
    implements _$PendingRequestResponseCopyWith<$Res> {
  __$PendingRequestResponseCopyWithImpl(this._self, this._then);

  final _PendingRequestResponse _self;
  final $Res Function(_PendingRequestResponse) _then;

/// Create a copy of PendingRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request_id = null,Object? username = null,Object? display_name = null,Object? profile_image = null,Object? created_at = null,}) {
  return _then(_PendingRequestResponse(
request_id: null == request_id ? _self.request_id : request_id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,profile_image: null == profile_image ? _self.profile_image : profile_image // ignore: cast_nullable_to_non_nullable
as String,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FriendResponse {

 String get id; String get username; String get display_name; String get status; String get friends_since;
/// Create a copy of FriendResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendResponseCopyWith<FriendResponse> get copyWith => _$FriendResponseCopyWithImpl<FriendResponse>(this as FriendResponse, _$identity);

  /// Serializes this FriendResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.status, status) || other.status == status)&&(identical(other.friends_since, friends_since) || other.friends_since == friends_since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,display_name,status,friends_since);

@override
String toString() {
  return 'FriendResponse(id: $id, username: $username, display_name: $display_name, status: $status, friends_since: $friends_since)';
}


}

/// @nodoc
abstract mixin class $FriendResponseCopyWith<$Res>  {
  factory $FriendResponseCopyWith(FriendResponse value, $Res Function(FriendResponse) _then) = _$FriendResponseCopyWithImpl;
@useResult
$Res call({
 String id, String username, String display_name, String status, String friends_since
});




}
/// @nodoc
class _$FriendResponseCopyWithImpl<$Res>
    implements $FriendResponseCopyWith<$Res> {
  _$FriendResponseCopyWithImpl(this._self, this._then);

  final FriendResponse _self;
  final $Res Function(FriendResponse) _then;

/// Create a copy of FriendResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? display_name = null,Object? status = null,Object? friends_since = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,friends_since: null == friends_since ? _self.friends_since : friends_since // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendResponse].
extension FriendResponsePatterns on FriendResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendResponse value)  $default,){
final _that = this;
switch (_that) {
case _FriendResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FriendResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String display_name,  String status,  String friends_since)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendResponse() when $default != null:
return $default(_that.id,_that.username,_that.display_name,_that.status,_that.friends_since);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String display_name,  String status,  String friends_since)  $default,) {final _that = this;
switch (_that) {
case _FriendResponse():
return $default(_that.id,_that.username,_that.display_name,_that.status,_that.friends_since);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String display_name,  String status,  String friends_since)?  $default,) {final _that = this;
switch (_that) {
case _FriendResponse() when $default != null:
return $default(_that.id,_that.username,_that.display_name,_that.status,_that.friends_since);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendResponse implements FriendResponse {
  const _FriendResponse({required this.id, required this.username, required this.display_name, required this.status, required this.friends_since});
  factory _FriendResponse.fromJson(Map<String, dynamic> json) => _$FriendResponseFromJson(json);

@override final  String id;
@override final  String username;
@override final  String display_name;
@override final  String status;
@override final  String friends_since;

/// Create a copy of FriendResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendResponseCopyWith<_FriendResponse> get copyWith => __$FriendResponseCopyWithImpl<_FriendResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.display_name, display_name) || other.display_name == display_name)&&(identical(other.status, status) || other.status == status)&&(identical(other.friends_since, friends_since) || other.friends_since == friends_since));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,display_name,status,friends_since);

@override
String toString() {
  return 'FriendResponse(id: $id, username: $username, display_name: $display_name, status: $status, friends_since: $friends_since)';
}


}

/// @nodoc
abstract mixin class _$FriendResponseCopyWith<$Res> implements $FriendResponseCopyWith<$Res> {
  factory _$FriendResponseCopyWith(_FriendResponse value, $Res Function(_FriendResponse) _then) = __$FriendResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String display_name, String status, String friends_since
});




}
/// @nodoc
class __$FriendResponseCopyWithImpl<$Res>
    implements _$FriendResponseCopyWith<$Res> {
  __$FriendResponseCopyWithImpl(this._self, this._then);

  final _FriendResponse _self;
  final $Res Function(_FriendResponse) _then;

/// Create a copy of FriendResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? display_name = null,Object? status = null,Object? friends_since = null,}) {
  return _then(_FriendResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,display_name: null == display_name ? _self.display_name : display_name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,friends_since: null == friends_since ? _self.friends_since : friends_since // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
