import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'feed_provider.dart';
import 'friend_provider.dart';
import 'notification_provider.dart';
import 'activity_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref, ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthNotifier(this._ref, this._repository) : super(AsyncValue.data(_repository.getCachedUser()));

  void _invalidateAll() {
    _ref.invalidate(feedProvider);
    _ref.invalidate(myAsksProvider);
    _ref.invalidate(friendsProvider);
    _ref.invalidate(pendingRequestsProvider);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(activityProvider);
  }

  Future<void> checkAuth() async {
    final prevUser = state.value;
    state = const AsyncValue.loading();
    try {
      final user = await _repository.fetchMe();
      state = AsyncValue.data(user);
    } catch (e, _) {
      if (e is DioException && e.response?.statusCode == 401) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(prevUser ?? _repository.getCachedUser());
      }
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(username, password);
      _invalidateAll();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        String errorMessage = e.message ?? 'Unknown error';
        if (data is Map<String, dynamic> && data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List) {
            errorMessage = detail.map((e) => e['msg'] ?? e.toString()).join(', ');
          }
        } else if (data is String) {
          errorMessage = data;
        }
        state = AsyncValue.error(errorMessage, stackTrace);
      } else {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(data);
      // Wait for login or auto-login depending on backend.
      // Usually, we just login automatically, but let's assume the user has to login
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        String errorMessage = e.message ?? 'Unknown error';
        if (data is Map<String, dynamic> && data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List) {
            errorMessage = detail.map((e) => e['msg'] ?? e.toString()).join(', ');
          }
        } else if (data is String) {
          errorMessage = data;
        }
        state = AsyncValue.error(errorMessage, stackTrace);
      } else {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _invalidateAll();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final prevState = state;
    state = const AsyncValue.loading();
    try {
      final user = await _repository.updateProfile(data);
      state = AsyncValue.data(user);
    } catch (e, _) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        String errorMessage = e.message ?? 'Unknown error';
        if (data is Map<String, dynamic> && data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List) {
            errorMessage = detail.map((e) => e['msg'] ?? e.toString()).join(', ');
          }
        } else if (data is String) {
          errorMessage = data;
        }
        throw Exception(errorMessage);
      }
      throw Exception(e.toString());
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _repository.changePassword(oldPassword, newPassword);
  }
}
