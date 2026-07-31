import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/ask.dart';
import '../services/dio_client.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.watch(dioProvider));
});

class FeedRepository {
  final Dio _dio;

  FeedRepository(this._dio);

  Future<List<Ask>> getFeed() async {
    final response = await _dio.get(ApiConstants.asksFeed);
    return (response.data as List).map((e) => Ask.fromJson(e)).toList();
  }

  Future<List<Ask>> getMyAsks() async {
    final response = await _dio.get(ApiConstants.asksMy);
    return (response.data as List).map((e) => Ask.fromJson(e)).toList();
  }

  Future<Ask> createAsk(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.asks, data: data);
    return Ask.fromJson(response.data);
  }

  Future<List<Reply>> getReplies(String askId) async {
    final response = await _dio.get(ApiConstants.askReplies(askId));
    return (response.data as List).map((e) => Reply.fromJson(e)).toList();
  }

  Future<void> createReply(String askId, String message, int? arrivalEtaMinutes) async {
    final Map<String, dynamic> data = {'message': message};
    if (arrivalEtaMinutes != null) {
      data['arrival_eta_minutes'] = arrivalEtaMinutes;
    }
    await _dio.post(
      ApiConstants.askReply(askId),
      data: data,
    );
  }

  Future<void> resolveAsk(String askId, String replyId) async {
    await _dio.post(
      ApiConstants.askResolve(askId),
      data: {'reply_id': replyId},
    );
  }

  Future<void> deleteAsk(String askId) async {
    await _dio.delete(ApiConstants.deleteAsk(askId));
  }
}
