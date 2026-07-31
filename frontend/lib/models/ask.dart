import 'package:freezed_annotation/freezed_annotation.dart';

part 'ask.freezed.dart';
part 'ask.g.dart';

@freezed
class Ask with _$Ask {
  const factory Ask({
    required String id,
    required String requester_id,
    required String requester_name,
    required String requester_image,
    required String title,
    required String description,
    required String category,
    required String location,
    required String status,
    required int reply_count,
    required int max_replies,
    required String created_at,
    required String expires_at,
  }) = _Ask;

  factory Ask.fromJson(Map<String, dynamic> json) => _$AskFromJson(json);
}

@freezed
class Reply with _$Reply {
  const factory Reply({
    required String id,
    required String ask_id,
    required String responder_id,
    required String responder_name,
    required String responder_image,
    required String message,
    required String created_at,
  }) = _Reply;

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);
}
