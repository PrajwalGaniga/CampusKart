import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.fetchMe();
      state = AsyncValue.data(user);
    } catch (e, _) {
      state = AsyncValue.data(null);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(username, password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // stackTrace used intentionally
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
      state = AsyncValue.error(e, stackTrace); // stackTrace used intentionally
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final prevState = state;
    state = const AsyncValue.loading();
    try {
      final user = await _repository.updateProfile(data);
      state = AsyncValue.data(user);
    } catch (e, _) {
      state = prevState; // Revert
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _repository.changePassword(oldPassword, newPassword);
  }
}
