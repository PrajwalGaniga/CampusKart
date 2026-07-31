import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/activity_provider.dart';
import 'package:intl/intl.dart';

class ActivityLogsScreen extends ConsumerWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
      ),
      body: activityState.when(
        data: (logs) {
          if (logs.isEmpty) return const Center(child: Text('No activity found.'));
          return RefreshIndicator(
            onRefresh: () => ref.read(activityProvider.notifier).fetchActivityLogs(),
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final dateStr = DateFormat('MMM d, y h:mm a').format(log.createdAt.toLocal());
                
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.history, size: 20),
                  ),
                  title: Text(
                    log.action.replaceAll('_', ' '), 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(dateStr),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    if (log.metadata.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Activity Details'),
                          content: Text(log.metadata.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
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
