import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_log.dart';
import '../repositories/activity_repository.dart';

final activityProvider = StateNotifierProvider<ActivityNotifier, AsyncValue<List<ActivityLog>>>((ref) {
  return ActivityNotifier(ref.watch(activityRepositoryProvider));
});

class ActivityNotifier extends StateNotifier<AsyncValue<List<ActivityLog>>> {
  final ActivityRepository _repository;

  ActivityNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchActivityLogs();
  }

  Future<void> fetchActivityLogs() async {
    try {
      final logs = await _repository.getActivityLogs();
      state = AsyncValue.data(logs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
