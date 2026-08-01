import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../routes/app_router.dart';
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
        
        bool isConnectionFailure = false;
        
        // ngrok interstitial returns HTML instead of JSON
        if (e.response?.data is String && (e.response?.data as String).toLowerCase().contains('<html')) {
          isConnectionFailure = true;
        } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          isConnectionFailure = true;
        }

        if (isConnectionFailure) {
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Connection Failure'),
                content: const Text('Connection failure. Please relogin.'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await secureStorage.deleteToken();
                      appRouter.go('/login');
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
        }

        if (e.response?.statusCode == 401) {
          await secureStorage.deleteToken();
          appRouter.go('/login');
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
