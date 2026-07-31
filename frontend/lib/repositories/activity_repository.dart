import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/activity_log.dart';
import '../services/dio_client.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ActivityRepository(dio);
});

class ActivityRepository {
  final Dio _dio;

  ActivityRepository(this._dio);

  Future<List<ActivityLog>> getActivityLogs() async {
    try {
      final response = await _dio.get('/api/v1/activity/');
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
