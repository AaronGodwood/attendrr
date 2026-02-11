import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friends_provider.dart';
import '../repositories/user_repository.dart';
import '../theme/theme_extensions.dart';
import '../widgets/friends/friend_card.dart';
import '../widgets/friends/friend_request_card.dart';
import '../widgets/friends/leaderboard_entry_tile.dart';
import '../widgets/friends/podium_widget.dart';

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
        final theme = Theme.of(context);
        final ext = theme.extension<TerraThemeExtension>();

        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        return RefreshIndicator(
          onRefresh: provider.loadFriends,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.requests.isNotEmpty) ...[
                Text(
                  'Friend Requests (${provider.requests.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.requests.map((r) => FriendRequestCard(
                  request: r,
                  onAccept: () => provider.acceptRequest(r.id),
                  onReject: () => provider.rejectRequest(r.id),
                )),
                const SizedBox(height: 24),
              ],

              Text(
                'My Friends (${provider.friends.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (provider.friends.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 64, color: ext?.textDisabled),
                        const SizedBox(height: 16),
                        Text(
                          'No friends yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: ext?.textSecondary,
                          ),
                        ),
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
        final theme = Theme.of(context);
        final ext = theme.extension<TerraThemeExtension>();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Global')),
                    ButtonSegment(value: false, label: Text('Friends')),
                  ],
                  selected: {provider.showGlobal},
                  onSelectionChanged: (_) => provider.toggleLeaderboardType(),
                ),
              ),
            ),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: provider.loadLeaderboard,
                child: provider.leaderboard.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard_outlined, size: 64, color: ext?.textDisabled),
                      const SizedBox(height: 16),
                      Text(
                        'No leaderboard data yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: ext?.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
                    : CustomScrollView(
                  slivers: [
                    // Podium for top 3
                    if (provider.leaderboard.isNotEmpty)
                      SliverToBoxAdapter(
                        child: PodiumWidget(
                          topThree: provider.leaderboard.take(3).toList(),
                        ),
                      ),

                    // Remaining entries with stagger animation
                    if (provider.leaderboard.length > 3)
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final actualIndex = index + 3;
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 400 + (index * 80)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: LeaderboardEntryTile(
                                  entry: provider.leaderboard[actualIndex],
                                ),
                              );
                            },
                            childCount: provider.leaderboard.length - 3,
                          ),
                        ),
                      ),
                  ],
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
