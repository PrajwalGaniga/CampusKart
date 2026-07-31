import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../repositories/friend_repository.dart';

final friendsProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<FriendResponse>>>((ref) {
  return FriendsNotifier(ref.watch(friendRepositoryProvider));
});

class FriendsNotifier extends StateNotifier<AsyncValue<List<FriendResponse>>> {
  final FriendRepository _repository;

  FriendsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      final friends = await _repository.getFriends();
      state = AsyncValue.data(friends);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _repository.removeFriend(friendId);
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((f) => f.id != friendId).toList());
      }
    } catch (e) {
      rethrow;
    }
  }
}

final pendingRequestsProvider = StateNotifierProvider<PendingRequestsNotifier, AsyncValue<List<PendingRequestResponse>>>((ref) {
  return PendingRequestsNotifier(ref.watch(friendRepositoryProvider));
});

class PendingRequestsNotifier extends StateNotifier<AsyncValue<List<PendingRequestResponse>>> {
  final FriendRepository _repository;

  PendingRequestsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final requests = await _repository.getPendingRequests();
      state = AsyncValue.data(requests);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _repository.acceptRequest(requestId);
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((r) => r.request_id != requestId).toList());
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _repository.rejectRequest(requestId);
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((r) => r.request_id != requestId).toList());
      }
    } catch (e) {
      rethrow;
    }
  }
}


