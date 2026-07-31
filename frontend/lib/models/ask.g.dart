// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ask.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ask _$AskFromJson(Map<String, dynamic> json) => _Ask(
  id: json['id'] as String,
  requester_id: json['requester_id'] as String,
  requester_name: json['requester_name'] as String,
  requester_image: json['requester_image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  location: json['location'] as String,
  status: json['status'] as String,
  reply_count: (json['reply_count'] as num).toInt(),
  max_replies: (json['max_replies'] as num).toInt(),
  created_at: json['created_at'] as String,
  expires_at: json['expires_at'] as String,
);

Map<String, dynamic> _$AskToJson(_Ask instance) => <String, dynamic>{
  'id': instance.id,
  'requester_id': instance.requester_id,
  'requester_name': instance.requester_name,
  'requester_image': instance.requester_image,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'status': instance.status,
  'reply_count': instance.reply_count,
  'max_replies': instance.max_replies,
  'created_at': instance.created_at,
  'expires_at': instance.expires_at,
};

_Reply _$ReplyFromJson(Map<String, dynamic> json) => _Reply(
  id: json['id'] as String,
  ask_id: json['ask_id'] as String,
  responder_id: json['responder_id'] as String,
  responder_name: json['responder_name'] as String,
  responder_image: json['responder_image'] as String,
  message: json['message'] as String,
  created_at: json['created_at'] as String,
);

Map<String, dynamic> _$ReplyToJson(_Reply instance) => <String, dynamic>{
  'id': instance.id,
  'ask_id': instance.ask_id,
  'responder_id': instance.responder_id,
  'responder_name': instance.responder_name,
  'responder_image': instance.responder_image,
  'message': instance.message,
  'created_at': instance.created_at,
};
