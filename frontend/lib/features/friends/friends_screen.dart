import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/friend_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();

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
                  onPressed: () => ref.read(friendsProvider.notifier).removeFriend(int.parse(friend.id)),
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
            decoration: InputDecoration(
              hintText: 'Search user to add...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implement search here or navigate to a search screen
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: requestsState.when(
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
                            onPressed: () => ref.read(pendingRequestsProvider.notifier).acceptRequest(int.parse(req.request_id)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => ref.read(pendingRequestsProvider.notifier).rejectRequest(int.parse(req.request_id)),
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
          ),
        ),
      ],
    );
  }
}
