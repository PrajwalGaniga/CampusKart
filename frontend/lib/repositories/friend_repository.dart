import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/friend.dart';
import '../services/dio_client.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.watch(dioProvider));
});

class FriendRepository {
  final Dio _dio;

  FriendRepository(this._dio);

  Future<List<FriendResponse>> getFriends() async {
    final response = await _dio.get(ApiConstants.friends);
    return (response.data as List).map((e) => FriendResponse.fromJson(e)).toList();
  }

  Future<List<UserSearchResponse>> searchUsers(String query) async {
    final response = await _dio.get('${ApiConstants.searchUsers}?q=$query');
    return (response.data as List).map((e) => UserSearchResponse.fromJson(e)).toList();
  }

  Future<void> sendFriendRequest(String username) async {
    await _dio.post(
      ApiConstants.friendRequests,
      data: {'username': username},
    );
  }

  Future<List<PendingRequestResponse>> getPendingRequests() async {
    final response = await _dio.get(ApiConstants.pendingRequests);
    return (response.data as List).map((e) => PendingRequestResponse.fromJson(e)).toList();
  }

  Future<void> acceptRequest(int requestId) async {
    await _dio.post(ApiConstants.acceptRequest, data: {'request_id': requestId.toString()});
  }

  Future<void> rejectRequest(int requestId) async {
    await _dio.post(ApiConstants.rejectRequest, data: {'request_id': requestId.toString()});
  }

  Future<void> cancelRequest(int requestId) async {
    await _dio.post(ApiConstants.cancelRequest, data: {'request_id': requestId.toString()});
  }

  Future<void> removeFriend(int friendId) async {
    await _dio.delete(ApiConstants.removeFriend(friendId));
  }
}
