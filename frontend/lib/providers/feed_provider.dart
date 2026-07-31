import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ask.dart';
import '../repositories/feed_repository.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<Ask>>>((ref) {
  return FeedNotifier(ref.watch(feedRepositoryProvider));
});

class FeedNotifier extends StateNotifier<AsyncValue<List<Ask>>> {
  final FeedRepository _repository;

  FeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    state = const AsyncValue.loading();
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

  Future<void> resolveAsk(int askId, String replyId) async {
    try {
      await _repository.resolveAsk(askId, replyId);
      // Optimistic update
      if (state.hasValue) {
        final asks = state.value!.map((ask) {
          if (ask.id == askId.toString()) {
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
}

final askRepliesProvider = FutureProvider.family<List<Reply>, int>((ref, askId) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getReplies(askId);
});
