import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
          ),
        ],
      ),
      body: notifsState.when(
        data: (notifications) {
          if (notifications.isEmpty) return const Center(child: Text('No notifications.'));
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).fetchNotifications(),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                  tileColor: notif.is_read ? null : Colors.blue.withOpacity(0.1),
                  title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notif.message),
                  trailing: notif.is_read
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.check, color: Colors.blue),
                          onPressed: () => ref.read(notificationsProvider.notifier).markAsRead(int.parse(notif.id)),
                        ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
