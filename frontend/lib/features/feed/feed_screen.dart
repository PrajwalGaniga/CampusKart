import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/ask.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campus Pulse'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'My Asks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FeedTab(),
            _MyAsksTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/create-ask'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final currentUser = ref.watch(authProvider).value;

    return feedState.when(
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
              return _AskCard(
                ask: ask,
                currentUser: currentUser,
                isMyAsk: false,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _MyAsksTab extends ConsumerWidget {
  const _MyAsksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAsksState = ref.watch(myAsksProvider);
    final currentUser = ref.watch(authProvider).value;

    return myAsksState.when(
      data: (asks) {
        if (asks.isEmpty) {
          return const Center(child: Text('You have not created any asks yet.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(myAsksProvider.notifier).fetchMyAsks(),
          child: ListView.builder(
            itemCount: asks.length,
            itemBuilder: (context, index) {
              final ask = asks[index];
              return _AskCard(
                ask: ask,
                currentUser: currentUser,
                isMyAsk: true,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _AskCard extends ConsumerWidget {
  final Ask ask;
  final dynamic currentUser;
  final bool isMyAsk;

  const _AskCard({
    required this.ask,
    required this.currentUser,
    required this.isMyAsk,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                if (isMyAsk)
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.6,
                          maxChildSize: 0.9,
                          minChildSize: 0.4,
                          expand: false,
                          builder: (context, scrollController) => _RepliesList(ask: ask, scrollController: scrollController),
                        ),
                      );
                    },
                    child: const Text('View Replies'),
                  )
                else if (currentUser != null && ask.requester_id != currentUser.id)
                  ref.read(feedProvider.notifier).repliedAskIds.contains(ask.id)
                      ? const ElevatedButton(
                          onPressed: null,
                          child: Text('Replied'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: _ReplyForm(askId: ask.id),
                              ),
                            );
                          },
                          child: const Text('Reply'),
                        )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _RepliesList extends ConsumerWidget {
  final Ask ask;
  final ScrollController scrollController;
  
  const _RepliesList({required this.ask, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesState = ref.watch(askRepliesProvider(ask.id));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Replies for "${ask.title}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: repliesState.when(
              data: (replies) {
                if (replies.isEmpty) {
                  return const Center(child: Text('No replies yet.'));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(reply.responder_image.startsWith('http') ? reply.responder_image : 'http://127.0.0.1:8000${reply.responder_image}'),
                          onBackgroundImageError: (_, __) {},
                          child: const Icon(Icons.person),
                        ),
                        title: Text(reply.responder_name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reply.message),
                            if (reply.arrival_eta_minutes != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('ETA: ${reply.arrival_eta_minutes} mins', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                          ],
                        ),
                        trailing: ask.status == 'OPEN'
                            ? IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                tooltip: 'Resolve Ask with this reply',
                                onPressed: () async {
                                  try {
                                    await ref.read(feedProvider.notifier).resolveAsk(ask.id, reply.id);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ask resolved!')));
                                      ref.read(myAsksProvider.notifier).fetchMyAsks();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resolve: $e')));
                                    }
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyForm extends ConsumerStatefulWidget {
  final String askId;
  const _ReplyForm({required this.askId});

  @override
  ConsumerState<_ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends ConsumerState<_ReplyForm> {
  final _controller = TextEditingController();
  final _customEtaController = TextEditingController();
  bool _isSubmitting = false;
  int? _selectedEta;
  bool _isCustomEta = false;

  void _submitReply() async {
    if (_isSubmitting) return;
    if (_controller.text.isEmpty) return;

    int? finalEta = _selectedEta;
    if (_isCustomEta) {
      final parsed = int.tryParse(_customEtaController.text);
      if (parsed != null && parsed > 0) {
        finalEta = parsed;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(feedProvider.notifier).replyToAsk(widget.askId, _controller.text, finalEta);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply posted!')));
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed: $e';
        if (e is DioException) {
          if (e.response?.data != null) {
            var data = e.response!.data;
            if (data is String) {
              try { data = jsonDecode(data); } catch (_) {}
            }
            if (data is Map && data.containsKey('detail')) {
              errorMessage = data['detail'].toString();
            } else {
              errorMessage = 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}';
            }
          } else {
             errorMessage = e.message ?? 'Unknown network error';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Write a Reply', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Type your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('ETA (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [2, 5, 10, 15, 20].map((mins) {
              return ChoiceChip(
                label: Text('$mins m'),
                selected: !_isCustomEta && _selectedEta == mins,
                onSelected: (selected) {
                  setState(() {
                    _isCustomEta = false;
                    _selectedEta = selected ? mins : null;
                  });
                },
              );
            }).toList()..add(
              ChoiceChip(
                label: const Text('Other'),
                selected: _isCustomEta,
                onSelected: (selected) {
                  setState(() {
                    _isCustomEta = selected;
                    if (selected) _selectedEta = null;
                  });
                },
              )
            ),
          ),
          if (_isCustomEta) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customEtaController,
              decoration: const InputDecoration(
                hintText: 'Enter minutes',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReply,
              child: _isSubmitting ? const CircularProgressIndicator() : const Text('Post Reply'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
