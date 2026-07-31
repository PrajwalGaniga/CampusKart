import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';
import '../services/dio_client.dart';
import '../services/secure_storage_service.dart';
import '../services/shared_prefs_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
    ref.watch(sharedPrefsProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final SharedPreferencesService _sharedPrefs;

  AuthRepository(this._dio, this._secureStorage, this._sharedPrefs);

  Future<User> login(String username, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );

    final token = AuthToken.fromJson(response.data);
    await _secureStorage.saveToken(token.access_token);
    await _secureStorage.saveRefreshToken(token.refresh_token);

    return await fetchMe();
  }

  Future<User> register(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.register, data: data);
    final user = User.fromJson(response.data);
    return user;
  }

  Future<User> fetchMe() async {
    final response = await _dio.get(ApiConstants.me);
    final user = User.fromJson(response.data);
    await _sharedPrefs.saveUser(response.data);
    return user;
  }

  User? getCachedUser() {
    final data = _sharedPrefs.getUser();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    await _sharedPrefs.clearUser();
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.me, data: data);
    final user = User.fromJson(response.data);
    await _sharedPrefs.saveUser(response.data);
    return user;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.put(
      ApiConstants.changePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }
}
