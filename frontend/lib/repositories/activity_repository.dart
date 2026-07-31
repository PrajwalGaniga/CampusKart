import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_log.dart';
import '../services/dio_client.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ActivityRepository(dioClient);
});

class ActivityRepository {
  final DioClient _dioClient;

  ActivityRepository(this._dioClient);

  Future<List<ActivityLog>> getActivityLogs() async {
    try {
      final response = await _dioClient.dio.get('/activity/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ActivityLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activity logs');
      }
    } catch (e) {
      rethrow;
    }
  }
}
