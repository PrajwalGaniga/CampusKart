import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/friend_provider.dart';
import '../../repositories/friend_repository.dart';
import '../../models/friend.dart';
import '../../core/app_theme.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  CancelToken? _searchCancelToken;
  List<UserSearchResponse> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _searchCancelToken?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _searchCancelToken?.cancel();
      _searchCancelToken = CancelToken();

      try {
        final repository = ref.read(friendRepositoryProvider);
        final results = await repository.searchUsers(query, cancelToken: _searchCancelToken);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) {
          // Cancelled, do nothing
        } else {
          if (mounted) {
            setState(() => _isSearching = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Search failed: $e'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: primaryGradientDecoration(radius: 0),
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                  child: const Text(
                    'Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  color: AppColors.surface,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'My Friends'),
                      Tab(text: 'Requests'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildFriendsList(),
              _buildRequestsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    final friendsState = ref.watch(friendsProvider);
    return friendsState.when(
      data: (friends) {
        if (friends.isEmpty) {
          return const _EmptyFriends(
            icon: Icons.people_outline_rounded,
            title: 'No friends yet',
            subtitle: 'Search and add friends in the Requests tab',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(friendsProvider.notifier).fetchFriends(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            separatorBuilder: (_, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Container(
                decoration: cardDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: _Avatar(name: friend.display_name),
                  title: Text(
                    friend.display_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '@${friend.username}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_remove_rounded, color: AppColors.error),
                    onPressed: () => _showRemoveDialog(friend),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  void _showRemoveDialog(FriendResponse friend) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Friend', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Remove ${friend.display_name} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(friendsProvider.notifier).removeFriend(friend.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    final requestsState = ref.watch(pendingRequestsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search users to add...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: _searchController.text.isNotEmpty
              ? _buildSearchResults()
              : _buildPendingRequests(requestsState),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const _EmptyFriends(
        icon: Icons.search_off_rounded,
        title: 'No users found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Container(
          decoration: cardDecoration(),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: _Avatar(name: user.display_name),
            title: Text(
              user.display_name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '@${user.username}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            trailing: _buildFriendshipAction(user),
          ),
        );
      },
    );
  }

  Widget _buildFriendshipAction(UserSearchResponse user) {
    if (user.friendship_status == 'FRIENDS') {
      return _StatusChip(label: 'Friends', color: AppColors.success);
    } else if (user.friendship_status == 'PENDING_SENT') {
      return _StatusChip(label: 'Sent', color: AppColors.warning);
    } else if (user.friendship_status == 'PENDING_RECEIVED') {
      return _StatusChip(label: 'Received', color: AppColors.accent);
    } else {
      return IconButton(
        icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
        onPressed: () async {
          try {
            await ref.read(friendRepositoryProvider).sendFriendRequest(user.username);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Friend request sent to ${user.display_name}!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              _onSearchChanged(_searchController.text);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        },
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildPendingRequests(AsyncValue<List<PendingRequestResponse>> requestsState) {
    return requestsState.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const _EmptyFriends(
            icon: Icons.inbox_outlined,
            title: 'No pending requests',
            subtitle: 'Friend requests will appear here',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(pendingRequestsProvider.notifier).fetchPendingRequests(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final req = requests[index];
              return Container(
                decoration: cardDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: _Avatar(name: req.display_name),
                  title: Text(
                    req.display_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '@${req.username}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                        onPressed: () async {
                              await ref.read(pendingRequestsProvider.notifier).acceptRequest(req.request_id);
                              ref.read(friendsProvider.notifier).fetchFriends();
                            },
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        onPressed: () =>
                            ref.read(pendingRequestsProvider.notifier).rejectRequest(req.request_id),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
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
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyFriends({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 36, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
