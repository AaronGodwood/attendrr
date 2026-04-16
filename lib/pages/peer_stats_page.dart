import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/peer_stats_provider.dart';
import '../models/models.dart';

class PeerStatsPage extends StatefulWidget {
  const PeerStatsPage({super.key});

  @override
  State<PeerStatsPage> createState() => _PeerStatsPageState();
}

class _PeerStatsPageState extends State<PeerStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PeerStatsProvider>();
      provider.loadGlobal();
      provider.loadFriends();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Global'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FriendsTab(),
          _GlobalTab(),
        ],
      ),
    );
  }
}

// ─── Friends Tab ─────────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PeerStatsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingFriends) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.friendsError != null) {
          return _ErrorView(
            message: provider.friendsError!,
            onRetry: provider.loadFriends,
          );
        }
        return Column(
          children: [
            _AddFriendBar(),
            Expanded(
              child: provider.friends.isEmpty
                  ? _EmptyFriends()
                  : _StatsTable(
                      rows: provider.friends,
                      showFriendAction: true,
                      onRefresh: provider.loadFriends,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _AddFriendBar extends StatefulWidget {
  @override
  State<_AddFriendBar> createState() => _AddFriendBarState();
}

class _AddFriendBarState extends State<_AddFriendBar> {
  final _controller = TextEditingController();
  List<User> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final users = await context
          .read<PeerStatsProvider>()
          .searchUsers(query.trim());
      setState(() => _results = users);
    } finally {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search by username…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _results = []);
                      },
                    )
                  : null,
            ),
            onChanged: _search,
          ),
        ),
        if (_searching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Consumer<PeerStatsProvider>(
              builder: (context, provider, _) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: theme.colorScheme.outline,
                  ),
                  itemBuilder: (context, i) {
                    final user = _results[i];
                    final already = provider.isFriend(user.id);
                    return ListTile(
                      dense: true,
                      title: Text(user.username),
                      trailing: already
                          ? const Icon(Icons.check, size: 18)
                          : TextButton(
                              onPressed: () async {
                                await provider.addFriend(user.id);
                                if (context.mounted) {
                                  _controller.clear();
                                  setState(() => _results = []);
                                }
                              },
                              child: const Text('Add'),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        if (_results.isNotEmpty) const SizedBox(height: 8),
        Divider(height: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Search by username above to add friends.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Global Tab ──────────────────────────────────────────────────────────────

class _GlobalTab extends StatelessWidget {
  const _GlobalTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PeerStatsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingGlobal) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.globalError != null) {
          return _ErrorView(
            message: provider.globalError!,
            onRetry: provider.loadGlobal,
          );
        }
        if (provider.global.isEmpty) {
          return Center(
            child: Text(
              'No other users yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return _StatsTable(
          rows: provider.global,
          showFriendAction: true,
          onRefresh: provider.loadGlobal,
        );
      },
    );
  }
}

// ─── Shared Stats Table ───────────────────────────────────────────────────────

class _StatsTable extends StatelessWidget {
  final List<UserStats> rows;
  final bool showFriendAction;
  final Future<void> Function() onRefresh;

  const _StatsTable({
    required this.rows,
    required this.showFriendAction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          // ── Header row ──────────────────────────────────────
          Container(
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'User',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                _HeaderCell('Week', theme),
                _HeaderCell('Month', theme),
                _HeaderCell('Overall', theme),
                if (showFriendAction) const SizedBox(width: 36),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outline),
          // ── Data rows ───────────────────────────────────────
          ...rows.map((entry) => _StatsRow(entry: entry, showAction: showFriendAction)),
        ],
      ),
    );
  }
}

Widget _HeaderCell(String label, ThemeData theme) {
  return SizedBox(
    width: 72,
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final UserStats entry;
  final bool showAction;

  const _StatsRow({required this.entry, required this.showAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = entry.stats;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Username
              Expanded(
                flex: 3,
                child: Text(
                  entry.user.username,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Weekly
              _StatCell('${s.weeklyAttended}/${s.weeklyTotal}', theme),
              // Monthly
              _StatCell('${s.monthlyAttended}/${s.monthlyTotal}', theme),
              // Overall
              _StatCell('${s.overallPercent}%', theme),
              // Friend action
              if (showAction)
                _FriendButton(userId: entry.user.id),
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}

Widget _StatCell(String text, ThemeData theme) {
  return SizedBox(
    width: 72,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium,
    ),
  );
}

class _FriendButton extends StatelessWidget {
  final String userId;

  const _FriendButton({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PeerStatsProvider>(
      builder: (context, provider, _) {
        final isFriend = provider.isFriend(userId);
        return SizedBox(
          width: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: Icon(
              isFriend ? Icons.person_remove_outlined : Icons.person_add_outlined,
              color: isFriend
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            tooltip: isFriend ? 'Remove friend' : 'Add friend',
            onPressed: () async {
              if (isFriend) {
                await provider.removeFriend(userId);
              } else {
                await provider.addFriend(userId);
              }
            },
          ),
        );
      },
    );
  }
}

// ─── Shared Error View ───────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
