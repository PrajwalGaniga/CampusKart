// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ask.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ask {

 String get id; String get requester_id; String get requester_name; String get requester_image; String get title; String get description; String get category; String get location; String get status; int get reply_count; int get max_replies; String get created_at; String get expires_at;
/// Create a copy of Ask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskCopyWith<Ask> get copyWith => _$AskCopyWithImpl<Ask>(this as Ask, _$identity);

  /// Serializes this Ask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ask&&(identical(other.id, id) || other.id == id)&&(identical(other.requester_id, requester_id) || other.requester_id == requester_id)&&(identical(other.requester_name, requester_name) || other.requester_name == requester_name)&&(identical(other.requester_image, requester_image) || other.requester_image == requester_image)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.status, status) || other.status == status)&&(identical(other.reply_count, reply_count) || other.reply_count == reply_count)&&(identical(other.max_replies, max_replies) || other.max_replies == max_replies)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.expires_at, expires_at) || other.expires_at == expires_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requester_id,requester_name,requester_image,title,description,category,location,status,reply_count,max_replies,created_at,expires_at);

@override
String toString() {
  return 'Ask(id: $id, requester_id: $requester_id, requester_name: $requester_name, requester_image: $requester_image, title: $title, description: $description, category: $category, location: $location, status: $status, reply_count: $reply_count, max_replies: $max_replies, created_at: $created_at, expires_at: $expires_at)';
}


}

/// @nodoc
abstract mixin class $AskCopyWith<$Res>  {
  factory $AskCopyWith(Ask value, $Res Function(Ask) _then) = _$AskCopyWithImpl;
@useResult
$Res call({
 String id, String requester_id, String requester_name, String requester_image, String title, String description, String category, String location, String status, int reply_count, int max_replies, String created_at, String expires_at
});




}
/// @nodoc
class _$AskCopyWithImpl<$Res>
    implements $AskCopyWith<$Res> {
  _$AskCopyWithImpl(this._self, this._then);

  final Ask _self;
  final $Res Function(Ask) _then;

/// Create a copy of Ask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requester_id = null,Object? requester_name = null,Object? requester_image = null,Object? title = null,Object? description = null,Object? category = null,Object? location = null,Object? status = null,Object? reply_count = null,Object? max_replies = null,Object? created_at = null,Object? expires_at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requester_id: null == requester_id ? _self.requester_id : requester_id // ignore: cast_nullable_to_non_nullable
as String,requester_name: null == requester_name ? _self.requester_name : requester_name // ignore: cast_nullable_to_non_nullable
as String,requester_image: null == requester_image ? _self.requester_image : requester_image // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reply_count: null == reply_count ? _self.reply_count : reply_count // ignore: cast_nullable_to_non_nullable
as int,max_replies: null == max_replies ? _self.max_replies : max_replies // ignore: cast_nullable_to_non_nullable
as int,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,expires_at: null == expires_at ? _self.expires_at : expires_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Ask].
extension AskPatterns on Ask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ask value)  $default,){
final _that = this;
switch (_that) {
case _Ask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ask value)?  $default,){
final _that = this;
switch (_that) {
case _Ask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String requester_id,  String requester_name,  String requester_image,  String title,  String description,  String category,  String location,  String status,  int reply_count,  int max_replies,  String created_at,  String expires_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ask() when $default != null:
return $default(_that.id,_that.requester_id,_that.requester_name,_that.requester_image,_that.title,_that.description,_that.category,_that.location,_that.status,_that.reply_count,_that.max_replies,_that.created_at,_that.expires_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String requester_id,  String requester_name,  String requester_image,  String title,  String description,  String category,  String location,  String status,  int reply_count,  int max_replies,  String created_at,  String expires_at)  $default,) {final _that = this;
switch (_that) {
case _Ask():
return $default(_that.id,_that.requester_id,_that.requester_name,_that.requester_image,_that.title,_that.description,_that.category,_that.location,_that.status,_that.reply_count,_that.max_replies,_that.created_at,_that.expires_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String requester_id,  String requester_name,  String requester_image,  String title,  String description,  String category,  String location,  String status,  int reply_count,  int max_replies,  String created_at,  String expires_at)?  $default,) {final _that = this;
switch (_that) {
case _Ask() when $default != null:
return $default(_that.id,_that.requester_id,_that.requester_name,_that.requester_image,_that.title,_that.description,_that.category,_that.location,_that.status,_that.reply_count,_that.max_replies,_that.created_at,_that.expires_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ask implements Ask {
  const _Ask({required this.id, required this.requester_id, required this.requester_name, required this.requester_image, required this.title, required this.description, required this.category, required this.location, required this.status, required this.reply_count, required this.max_replies, required this.created_at, required this.expires_at});
  factory _Ask.fromJson(Map<String, dynamic> json) => _$AskFromJson(json);

@override final  String id;
@override final  String requester_id;
@override final  String requester_name;
@override final  String requester_image;
@override final  String title;
@override final  String description;
@override final  String category;
@override final  String location;
@override final  String status;
@override final  int reply_count;
@override final  int max_replies;
@override final  String created_at;
@override final  String expires_at;

/// Create a copy of Ask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AskCopyWith<_Ask> get copyWith => __$AskCopyWithImpl<_Ask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ask&&(identical(other.id, id) || other.id == id)&&(identical(other.requester_id, requester_id) || other.requester_id == requester_id)&&(identical(other.requester_name, requester_name) || other.requester_name == requester_name)&&(identical(other.requester_image, requester_image) || other.requester_image == requester_image)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.status, status) || other.status == status)&&(identical(other.reply_count, reply_count) || other.reply_count == reply_count)&&(identical(other.max_replies, max_replies) || other.max_replies == max_replies)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.expires_at, expires_at) || other.expires_at == expires_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requester_id,requester_name,requester_image,title,description,category,location,status,reply_count,max_replies,created_at,expires_at);

@override
String toString() {
  return 'Ask(id: $id, requester_id: $requester_id, requester_name: $requester_name, requester_image: $requester_image, title: $title, description: $description, category: $category, location: $location, status: $status, reply_count: $reply_count, max_replies: $max_replies, created_at: $created_at, expires_at: $expires_at)';
}


}

/// @nodoc
abstract mixin class _$AskCopyWith<$Res> implements $AskCopyWith<$Res> {
  factory _$AskCopyWith(_Ask value, $Res Function(_Ask) _then) = __$AskCopyWithImpl;
@override @useResult
$Res call({
 String id, String requester_id, String requester_name, String requester_image, String title, String description, String category, String location, String status, int reply_count, int max_replies, String created_at, String expires_at
});




}
/// @nodoc
class __$AskCopyWithImpl<$Res>
    implements _$AskCopyWith<$Res> {
  __$AskCopyWithImpl(this._self, this._then);

  final _Ask _self;
  final $Res Function(_Ask) _then;

/// Create a copy of Ask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requester_id = null,Object? requester_name = null,Object? requester_image = null,Object? title = null,Object? description = null,Object? category = null,Object? location = null,Object? status = null,Object? reply_count = null,Object? max_replies = null,Object? created_at = null,Object? expires_at = null,}) {
  return _then(_Ask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requester_id: null == requester_id ? _self.requester_id : requester_id // ignore: cast_nullable_to_non_nullable
as String,requester_name: null == requester_name ? _self.requester_name : requester_name // ignore: cast_nullable_to_non_nullable
as String,requester_image: null == requester_image ? _self.requester_image : requester_image // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reply_count: null == reply_count ? _self.reply_count : reply_count // ignore: cast_nullable_to_non_nullable
as int,max_replies: null == max_replies ? _self.max_replies : max_replies // ignore: cast_nullable_to_non_nullable
as int,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,expires_at: null == expires_at ? _self.expires_at : expires_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Reply {

 String get id; String get ask_id; String get responder_id; String get responder_name; String get responder_image; String get message; int? get arrival_eta_minutes; String? get estimated_arrival_time; String get created_at;
/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplyCopyWith<Reply> get copyWith => _$ReplyCopyWithImpl<Reply>(this as Reply, _$identity);

  /// Serializes this Reply to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reply&&(identical(other.id, id) || other.id == id)&&(identical(other.ask_id, ask_id) || other.ask_id == ask_id)&&(identical(other.responder_id, responder_id) || other.responder_id == responder_id)&&(identical(other.responder_name, responder_name) || other.responder_name == responder_name)&&(identical(other.responder_image, responder_image) || other.responder_image == responder_image)&&(identical(other.message, message) || other.message == message)&&(identical(other.arrival_eta_minutes, arrival_eta_minutes) || other.arrival_eta_minutes == arrival_eta_minutes)&&(identical(other.estimated_arrival_time, estimated_arrival_time) || other.estimated_arrival_time == estimated_arrival_time)&&(identical(other.created_at, created_at) || other.created_at == created_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ask_id,responder_id,responder_name,responder_image,message,arrival_eta_minutes,estimated_arrival_time,created_at);

@override
String toString() {
  return 'Reply(id: $id, ask_id: $ask_id, responder_id: $responder_id, responder_name: $responder_name, responder_image: $responder_image, message: $message, arrival_eta_minutes: $arrival_eta_minutes, estimated_arrival_time: $estimated_arrival_time, created_at: $created_at)';
}


}

/// @nodoc
abstract mixin class $ReplyCopyWith<$Res>  {
  factory $ReplyCopyWith(Reply value, $Res Function(Reply) _then) = _$ReplyCopyWithImpl;
@useResult
$Res call({
 String id, String ask_id, String responder_id, String responder_name, String responder_image, String message, int? arrival_eta_minutes, String? estimated_arrival_time, String created_at
});




}
/// @nodoc
class _$ReplyCopyWithImpl<$Res>
    implements $ReplyCopyWith<$Res> {
  _$ReplyCopyWithImpl(this._self, this._then);

  final Reply _self;
  final $Res Function(Reply) _then;

/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ask_id = null,Object? responder_id = null,Object? responder_name = null,Object? responder_image = null,Object? message = null,Object? arrival_eta_minutes = freezed,Object? estimated_arrival_time = freezed,Object? created_at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ask_id: null == ask_id ? _self.ask_id : ask_id // ignore: cast_nullable_to_non_nullable
as String,responder_id: null == responder_id ? _self.responder_id : responder_id // ignore: cast_nullable_to_non_nullable
as String,responder_name: null == responder_name ? _self.responder_name : responder_name // ignore: cast_nullable_to_non_nullable
as String,responder_image: null == responder_image ? _self.responder_image : responder_image // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,arrival_eta_minutes: freezed == arrival_eta_minutes ? _self.arrival_eta_minutes : arrival_eta_minutes // ignore: cast_nullable_to_non_nullable
as int?,estimated_arrival_time: freezed == estimated_arrival_time ? _self.estimated_arrival_time : estimated_arrival_time // ignore: cast_nullable_to_non_nullable
as String?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Reply].
extension ReplyPatterns on Reply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reply value)  $default,){
final _that = this;
switch (_that) {
case _Reply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reply value)?  $default,){
final _that = this;
switch (_that) {
case _Reply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ask_id,  String responder_id,  String responder_name,  String responder_image,  String message,  int? arrival_eta_minutes,  String? estimated_arrival_time,  String created_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reply() when $default != null:
return $default(_that.id,_that.ask_id,_that.responder_id,_that.responder_name,_that.responder_image,_that.message,_that.arrival_eta_minutes,_that.estimated_arrival_time,_that.created_at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ask_id,  String responder_id,  String responder_name,  String responder_image,  String message,  int? arrival_eta_minutes,  String? estimated_arrival_time,  String created_at)  $default,) {final _that = this;
switch (_that) {
case _Reply():
return $default(_that.id,_that.ask_id,_that.responder_id,_that.responder_name,_that.responder_image,_that.message,_that.arrival_eta_minutes,_that.estimated_arrival_time,_that.created_at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ask_id,  String responder_id,  String responder_name,  String responder_image,  String message,  int? arrival_eta_minutes,  String? estimated_arrival_time,  String created_at)?  $default,) {final _that = this;
switch (_that) {
case _Reply() when $default != null:
return $default(_that.id,_that.ask_id,_that.responder_id,_that.responder_name,_that.responder_image,_that.message,_that.arrival_eta_minutes,_that.estimated_arrival_time,_that.created_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reply implements Reply {
  const _Reply({required this.id, required this.ask_id, required this.responder_id, required this.responder_name, required this.responder_image, required this.message, this.arrival_eta_minutes, this.estimated_arrival_time, required this.created_at});
  factory _Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);

@override final  String id;
@override final  String ask_id;
@override final  String responder_id;
@override final  String responder_name;
@override final  String responder_image;
@override final  String message;
@override final  int? arrival_eta_minutes;
@override final  String? estimated_arrival_time;
@override final  String created_at;

/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplyCopyWith<_Reply> get copyWith => __$ReplyCopyWithImpl<_Reply>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reply&&(identical(other.id, id) || other.id == id)&&(identical(other.ask_id, ask_id) || other.ask_id == ask_id)&&(identical(other.responder_id, responder_id) || other.responder_id == responder_id)&&(identical(other.responder_name, responder_name) || other.responder_name == responder_name)&&(identical(other.responder_image, responder_image) || other.responder_image == responder_image)&&(identical(other.message, message) || other.message == message)&&(identical(other.arrival_eta_minutes, arrival_eta_minutes) || other.arrival_eta_minutes == arrival_eta_minutes)&&(identical(other.estimated_arrival_time, estimated_arrival_time) || other.estimated_arrival_time == estimated_arrival_time)&&(identical(other.created_at, created_at) || other.created_at == created_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ask_id,responder_id,responder_name,responder_image,message,arrival_eta_minutes,estimated_arrival_time,created_at);

@override
String toString() {
  return 'Reply(id: $id, ask_id: $ask_id, responder_id: $responder_id, responder_name: $responder_name, responder_image: $responder_image, message: $message, arrival_eta_minutes: $arrival_eta_minutes, estimated_arrival_time: $estimated_arrival_time, created_at: $created_at)';
}


}

/// @nodoc
abstract mixin class _$ReplyCopyWith<$Res> implements $ReplyCopyWith<$Res> {
  factory _$ReplyCopyWith(_Reply value, $Res Function(_Reply) _then) = __$ReplyCopyWithImpl;
@override @useResult
$Res call({
 String id, String ask_id, String responder_id, String responder_name, String responder_image, String message, int? arrival_eta_minutes, String? estimated_arrival_time, String created_at
});




}
/// @nodoc
class __$ReplyCopyWithImpl<$Res>
    implements _$ReplyCopyWith<$Res> {
  __$ReplyCopyWithImpl(this._self, this._then);

  final _Reply _self;
  final $Res Function(_Reply) _then;

/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ask_id = null,Object? responder_id = null,Object? responder_name = null,Object? responder_image = null,Object? message = null,Object? arrival_eta_minutes = freezed,Object? estimated_arrival_time = freezed,Object? created_at = null,}) {
  return _then(_Reply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ask_id: null == ask_id ? _self.ask_id : ask_id // ignore: cast_nullable_to_non_nullable
as String,responder_id: null == responder_id ? _self.responder_id : responder_id // ignore: cast_nullable_to_non_nullable
as String,responder_name: null == responder_name ? _self.responder_name : responder_name // ignore: cast_nullable_to_non_nullable
as String,responder_image: null == responder_image ? _self.responder_image : responder_image // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,arrival_eta_minutes: freezed == arrival_eta_minutes ? _self.arrival_eta_minutes : arrival_eta_minutes // ignore: cast_nullable_to_non_nullable
as int?,estimated_arrival_time: freezed == estimated_arrival_time ? _self.estimated_arrival_time : estimated_arrival_time // ignore: cast_nullable_to_non_nullable
as String?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
