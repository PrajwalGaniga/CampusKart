import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/ask.dart';
import '../../core/app_theme.dart';
import '../../widgets/user_avatar.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 110,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: primaryGradientDecoration(radius: 0),
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus Pulse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'See what\'s happening around campus',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  color: AppColors.surface,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Feed'),
                      Tab(text: 'My Asks'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _FeedTab(),
              _MyAsksTab(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/create-ask'),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Ask',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
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
          return _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No asks yet',
            subtitle: 'Be the first to post an ask!',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(feedProvider.notifier).fetchFeed(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: asks.length,
            separatorBuilder: (_, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ask = asks[index];
              return _AskCard(ask: ask, currentUser: currentUser, isMyAsk: false);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(message: error.toString()),
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
          return _EmptyState(
            icon: Icons.post_add_rounded,
            title: 'No asks yet',
            subtitle: 'Tap + to create your first ask',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(myAsksProvider.notifier).fetchMyAsks(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: asks.length,
            separatorBuilder: (_, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ask = asks[index];
              return _AskCard(ask: ask, currentUser: currentUser, isMyAsk: true);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(message: error.toString()),
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
    final catColor = categoryColor(ask.category);
    final isOpen = ask.status == 'OPEN';

    return Container(
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category accent bar
            Container(height: 4, color: catColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info
                  Row(
                    children: [
                      UserAvatar(profilePicture: ask.requester_image, radius: 14),
                      const SizedBox(width: 8),
                      Text(
                        ask.requester_name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon(ask.category), size: 13, color: catColor),
                            const SizedBox(width: 4),
                            Text(
                              ask.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: catColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppColors.success.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ask.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOpen ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (isMyAsk) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Ask'),
                                content: const Text('Are you sure you want to delete this ask?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true), 
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await ref.read(myAsksProvider.notifier).deleteAsk(ask.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ask deleted')));
                                }
                              } catch(e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    ask.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    ask.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Location + replies row
                  Row(
                    children: [
                      Icon(Icons.place_rounded, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          ask.location,
                          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(
                        '${ask.reply_count}/${ask.max_replies}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Action button
                  if (isMyAsk)
                    _ActionButton(
                      label: 'View Replies',
                      icon: Icons.reply_rounded,
                      color: AppColors.primary,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            maxChildSize: 0.9,
                            minChildSize: 0.4,
                            expand: false,
                            builder: (context, scrollController) =>
                                _RepliesList(ask: ask, scrollController: scrollController),
                          ),
                        );
                      },
                    )
                  else if (currentUser != null && ask.requester_id != currentUser.id)
                    ref.read(feedProvider.notifier).repliedAskIds.contains(ask.id)
                        ? _ActionButton(
                            label: 'Replied',
                            icon: Icons.check_rounded,
                            color: AppColors.success,
                            onPressed: null,
                          )
                        : _ActionButton(
                            label: 'Reply',
                            icon: Icons.send_rounded,
                            color: AppColors.primary,
                            onPressed: isOpen
                                ? () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: _ReplyForm(askId: ask.id),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey.shade200 : color,
          foregroundColor: onPressed == null ? AppColors.textSecondary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          minimumSize: Size.zero,
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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Replies for "${ask.title}"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: repliesState.when(
              data: (replies) {
                if (replies.isEmpty) {
                  return _EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No replies yet',
                    subtitle: 'Waiting for someone to respond',
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: replies.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    return Container(
                      decoration: cardDecoration(
                        shadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: UserAvatar(
                          profilePicture: reply.responder_image,
                          radius: 22,
                        ),
                        title: Text(
                          reply.responder_name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              reply.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (reply.arrival_eta_minutes != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '🕐 ETA: ${reply.arrival_eta_minutes} mins',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: ask.status == 'OPEN'
                            ? IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                                tooltip: 'Resolve with this reply',
                                onPressed: () async {
                                  try {
                                    await ref.read(feedProvider.notifier).resolveAsk(ask.id, reply.id);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Ask resolved! 🎉'),
                                          backgroundColor: AppColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                      ref.read(myAsksProvider.notifier).fetchMyAsks();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed: $e')),
                                      );
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
              error: (error, _) => _ErrorState(message: error.toString()),
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

  @override
  void dispose() {
    _controller.dispose();
    _customEtaController.dispose();
    super.dispose();
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply posted! 🚀'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed: $e';
        if (e is DioException) {
          if (e.response?.data != null) {
            var data = e.response!.data;
            if (data is String) {
              try {
                data = jsonDecode(data);
              } catch (_) {}
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Write a Reply',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Type your reply here...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            'ETA (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...[2, 5, 10, 15, 20].map((mins) {
                final isSelected = !_isCustomEta && _selectedEta == mins;
                return GestureDetector(
                  onTap: () => setState(() {
                    _isCustomEta = false;
                    _selectedEta = isSelected ? null : mins;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$mins min',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () => setState(() {
                  _isCustomEta = !_isCustomEta;
                  if (_isCustomEta) _selectedEta = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCustomEta ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Custom',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isCustomEta ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isCustomEta) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customEtaController,
              decoration: const InputDecoration(
                hintText: 'Enter minutes',
                isDense: true,
                prefixIcon: Icon(Icons.timer_outlined, color: AppColors.textSecondary),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isSubmitting ? null : _submitReply,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: _isSubmitting
                  ? BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(13),
                    )
                  : primaryGradientDecoration(radius: 13),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Post Reply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helper widgets ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
