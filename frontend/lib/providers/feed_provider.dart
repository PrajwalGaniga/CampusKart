import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ask.dart';
import '../repositories/feed_repository.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<Ask>>>((ref) {
  return FeedNotifier(ref.watch(feedRepositoryProvider));
});

class FeedNotifier extends StateNotifier<AsyncValue<List<Ask>>> {
  final FeedRepository _repository;
  final Set<String> repliedAskIds = {};

  FeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    try {
      final feed = await _repository.getFeed();
      state = AsyncValue.data(feed);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createAsk(Map<String, dynamic> data) async {
    try {
      final ask = await _repository.createAsk(data);
      if (state.hasValue) {
        state = AsyncValue.data([ask, ...state.value!]);
      }
    } catch (e) {
      // Handle error (maybe rethrow)
      rethrow;
    }
  }

  Future<void> resolveAsk(String askId, String replyId) async {
    try {
      await _repository.resolveAsk(askId, replyId);
      // Optimistic update
      if (state.hasValue) {
        final asks = state.value!.map((ask) {
          if (ask.id == askId) {
            return ask.copyWith(status: 'RESOLVED'); // Update status
          }
          return ask;
        }).toList();
        state = AsyncValue.data(asks);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyToAsk(String askId, String message, int? arrivalEtaMinutes) async {
    // Optimistic Update
    List<Ask>? previousState;
    if (state.hasValue) {
      previousState = state.value;
      repliedAskIds.add(askId);
      final asks = previousState!.map((ask) {
        if (ask.id == askId) {
          return ask.copyWith(reply_count: ask.reply_count + 1);
        }
        return ask;
      }).toList();
      state = AsyncValue.data(asks);
    }

    try {
      await _repository.createReply(askId, message, arrivalEtaMinutes);
    } catch (e) {
      // Rollback on failure
      repliedAskIds.remove(askId);
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      }
      rethrow;
    }
  }
}

final askRepliesProvider = FutureProvider.family<List<Reply>, String>((ref, askId) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getReplies(askId);
});

final myAsksProvider = StateNotifierProvider<MyAsksNotifier, AsyncValue<List<Ask>>>((ref) {
  return MyAsksNotifier(ref.watch(feedRepositoryProvider));
});

class MyAsksNotifier extends StateNotifier<AsyncValue<List<Ask>>> {
  final FeedRepository _repository;

  MyAsksNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchMyAsks();
  }

  Future<void> fetchMyAsks() async {
    try {
      final asks = await _repository.getMyAsks();
      state = AsyncValue.data(asks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createAsk(Map<String, dynamic> data) async {
    try {
      final ask = await _repository.createAsk(data);
      if (state.hasValue) {
        state = AsyncValue.data([ask, ...state.value!]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAsk(String askId) async {
    try {
      await _repository.deleteAsk(askId);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((a) => a.id != askId).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
