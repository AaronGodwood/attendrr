import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendsLeaderboardPage extends StatelessWidget {
  const FriendsLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends & Leaderboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => context.push('/friends/add'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FriendsView(),
            LeaderboardView(),
          ],
        ),
      ),
    );
  }
}

class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Template data for friends
    final friends = [
      {'name': 'Alice Smith', 'points': 520, 'streak': 15, 'avatar': 'A'},
      {'name': 'Bob Johnson', 'points': 480, 'streak': 10, 'avatar': 'B'},
      {'name': 'Carol Williams', 'points': 445, 'streak': 8, 'avatar': 'C'},
      {'name': 'David Brown', 'points': 420, 'streak': 12, 'avatar': 'D'},
    ];

    final friendRequests = [
      {'name': 'Eve Davis', 'avatar': 'E'},
    ];

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Friend Requests Section
          if (friendRequests.isNotEmpty) ...[
            const Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...friendRequests.map((request) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(request['avatar'] as String),
                    ),
                    title: Text(request['name'] as String),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 24),
          ],

          // Friends List
          Text(
            'My Friends (${friends.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (friends.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No friends yet'),
                  TextButton(
                    onPressed: () => context.push('/friends/add'),
                    child: const Text('Add Friends'),
                  ),
                ],
              ),
            )
          else
            ...friends.map((friend) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        friend['avatar'] as String,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(friend['name'] as String),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${friend['points']} pts'),
                        const SizedBox(width: 16),
                        const Icon(Icons.local_fire_department,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('${friend['streak']} days'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove Friend'),
                        ),
                      ],
                      onSelected: (value) {
                        // Handle menu selection
                      },
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  bool showGlobal = true;

  @override
  Widget build(BuildContext context) {
    // Template data for leaderboard
    final leaderboard = [
      {
        'name': 'Sarah Johnson',
        'points': 850,
        'attendanceRate': 95,
        'isCurrentUser': false
      },
      {
        'name': 'Mike Chen',
        'points': 720,
        'attendanceRate': 92,
        'isCurrentUser': false
      },
      {
        'name': 'Emma Wilson',
        'points': 680,
        'attendanceRate': 90,
        'isCurrentUser': false
      },
      {
        'name': 'You',
        'points': 450,
        'attendanceRate': 85,
        'isCurrentUser': true
      },
      {
        'name': 'Tom Anderson',
        'points': 420,
        'attendanceRate': 82,
        'isCurrentUser': false
      },
      {
        'name': 'Lisa Garcia',
        'points': 380,
        'attendanceRate': 78,
        'isCurrentUser': false
      },
    ];

    return Column(
      children: [
        // Toggle between Global and Friends
        Container(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Global')),
              ButtonSegment(value: false, label: Text('Friends')),
            ],
            selected: {showGlobal},
            onSelectionChanged: (Set<bool> selection) {
              setState(() => showGlobal = selection.first);
            },
          ),
        ),

        // Leaderboard List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final isCurrentUser = entry['isCurrentUser'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : null,
                    border: isCurrentUser
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRankColor(index + 1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      entry['name'] as String,
                      style: TextStyle(
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('${entry['attendanceRate']}% attendance'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry['points']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'points',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}
