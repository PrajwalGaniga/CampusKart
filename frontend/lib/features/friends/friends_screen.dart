import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/friend_provider.dart';
import '../../repositories/friend_repository.dart';
import '../../models/friend.dart';

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

    setState(() {
      _isSearching = true;
    });

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
            setState(() {
              _isSearching = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed: $e')));
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
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendsList(),
            _buildRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    final friendsState = ref.watch(friendsProvider);
    return friendsState.when(
      data: (friends) {
        if (friends.isEmpty) return const Center(child: Text('No friends yet.'));
        return RefreshIndicator(
          onRefresh: () => ref.read(friendsProvider.notifier).fetchFriends(),
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(child: Text(friend.display_name[0])),
                title: Text(friend.display_name),
                subtitle: Text('@${friend.username}'),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove, color: Colors.red),
                  onPressed: () => ref.read(friendsProvider.notifier).removeFriend(friend.id),
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

  Widget _buildRequestsList() {
    final requestsState = ref.watch(pendingRequestsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search user to add...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
                border: const OutlineInputBorder(),
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
      return const Center(child: Text('No users found.'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(child: Text(user.display_name[0])),
          title: Text(user.display_name),
          subtitle: Text('@${user.username}'),
          trailing: _buildFriendshipAction(user),
        );
      },
    );
  }

  Widget _buildFriendshipAction(UserSearchResponse user) {
    if (user.friendship_status == 'FRIENDS') {
      return const Chip(label: Text('Friends'), backgroundColor: Colors.green);
    } else if (user.friendship_status == 'PENDING_SENT') {
      return const Chip(label: Text('Request Sent'));
    } else if (user.friendship_status == 'PENDING_RECEIVED') {
      return const Chip(label: Text('Request Received'), backgroundColor: Colors.orange);
    } else {
      return IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: () async {
          try {
            await ref.read(friendRepositoryProvider).sendFriendRequest(user.username);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent!')));
              _onSearchChanged(_searchController.text); // Refresh search
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
      );
    }
  }

  Widget _buildPendingRequests(AsyncValue<List<PendingRequestResponse>> requestsState) {
    return requestsState.when(
            data: (requests) {
              if (requests.isEmpty) return const Center(child: Text('No pending requests.'));
              return RefreshIndicator(
                onRefresh: () => ref.read(pendingRequestsProvider.notifier).fetchPendingRequests(),
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(req.display_name[0])),
                      title: Text(req.display_name),
                      subtitle: Text('@${req.username}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => ref.read(pendingRequestsProvider.notifier).acceptRequest(req.request_id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => ref.read(pendingRequestsProvider.notifier).rejectRequest(req.request_id),
                          ),
                        ],
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
