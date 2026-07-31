import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import 'friend_provider.dart';
import 'feed_provider.dart';
import 'dart:developer';

final wsHandlerProvider = Provider<void>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  
  wsService.messages.listen((data) {
    if (!data.containsKey('event')) return;
    final event = data['event'];
    log('WS Handler received event: $event');
    
    switch (event) {
      case 'friend_request':
        // Someone sent us a friend request -> refresh pending requests
        ref.read(pendingRequestsProvider.notifier).fetchPendingRequests();
        break;
      case 'friend_accepted':
        // Someone accepted our friend request -> refresh friends list
        ref.read(friendsProvider.notifier).fetchFriends();
        break;
      case 'ask_created':
        // A friend created a new ask -> refresh feed
        ref.read(feedProvider.notifier).fetchFeed();
        break;
    }
  });
});
