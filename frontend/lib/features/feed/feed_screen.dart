import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feed_provider.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: feedState.when(
        data: (asks) {
          if (asks.isEmpty) {
            return const Center(child: Text('No asks yet.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(feedProvider.notifier).fetchFeed(),
            child: ListView.builder(
              itemCount: asks.length,
              itemBuilder: (context, index) {
                final ask = asks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ask.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text(ask.status, style: TextStyle(color: ask.status == 'OPEN' ? Colors.green : Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(ask.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(ask.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(ask.location, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${ask.reply_count} / ${ask.max_replies} replies'),
                            ElevatedButton(
                              onPressed: () {
                                // Show replies or add reply
                              },
                              child: const Text('Reply'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-ask'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
