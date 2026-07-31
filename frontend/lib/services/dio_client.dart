import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';
import 'dart:developer';

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        log('REQ: ${options.method} ${options.uri}\nBODY: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('RES: ${response.statusCode} ${response.requestOptions.uri}\nDATA: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        log('ERR: ${e.response?.statusCode} ${e.requestOptions.uri} - ${e.message}\nRESPONSE: ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          // Token might be expired. Handle token refresh here if applicable,
          // or log out the user.
          // For now, we'll just delete the token.
          await secureStorage.deleteToken();
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
