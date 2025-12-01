import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friends_provider.dart';
import '../repositories/user_repository.dart';
import '../widgets/friends/friend_card.dart';
import '../widgets/friends/friend_request_card.dart';
import '../widgets/friends/leaderboard_entry_tile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FriendsProvider>();
      provider.loadFriends();
      provider.loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Leaderboard'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: _showAddFriend),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Friends'), Tab(text: 'Leaderboard')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFriendsTab(), _buildLeaderboardTab()],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer<FriendsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        return RefreshIndicator(
          onRefresh: provider.loadFriends,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.requests.isNotEmpty) ...[
                Text('Friend Requests (${provider.requests.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...provider.requests.map((r) => FriendRequestCard(
                  request: r,
                  onAccept: () => provider.acceptRequest(r.id),
                  onReject: () => provider.rejectRequest(r.id),
                )),
                const SizedBox(height: 24),
              ],

              Text('My Friends (${provider.friends.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (provider.friends.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No friends yet'),
                        TextButton(onPressed: _showAddFriend, child: const Text('Add Friends')),
                      ],
                    ),
                  ),
                )
              else
                ...provider.friends.map((f) => FriendCard(
                  friend: f,
                  onRemove: () => provider.removeFriend(f.friendshipId),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab() {
    return Consumer<FriendsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Global')),
                  ButtonSegment(value: false, label: Text('Friends')),
                ],
                selected: {provider.showGlobal},
                onSelectionChanged: (_) => provider.toggleLeaderboardType(),
              ),
            ),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: provider.loadLeaderboard,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.leaderboard.length,
                  itemBuilder: (context, index) {
                    return LeaderboardEntryTile(entry: provider.leaderboard[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddFriend() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Search by username'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final users = await UserRepository.instance.searchUsers(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                _showSearchResults(users);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showSearchResults(List users) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: users.isEmpty
              ? const Text('No users found')
              : ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user.initials)),
                title: Text(user.username),
                trailing: IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    context.read<FriendsProvider>().sendRequest(user.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request sent!')));
                  },
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}