import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return WebSocketService(secureStorage);
});

class WebSocketService {
  final SecureStorageService _secureStorage;
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  WebSocketService(this._secureStorage);

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _secureStorage.getToken();
    if (token == null) return;

    try {
      final wsUrl = Uri.parse('${ApiConstants.wsUrl}?token=$token');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _isConnected = true;
      log('WebSocket connected');

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            _messageController.add(data as Map<String, dynamic>);
          } catch (e) {
            log('WebSocket decode error: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          log('WebSocket closed');
          _scheduleReconnect();
        },
        onError: (error) {
          _isConnected = false;
          log('WebSocket error: $error');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      log('WebSocket connection error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      log('Attempting to reconnect WebSocket...');
      connect();
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    if (_channel != null && _isConnected) {
      _channel!.sink.close(status.normalClosure);
    }
    _isConnected = false;
  }
}
