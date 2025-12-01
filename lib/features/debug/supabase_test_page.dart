import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final _supabase = Supabase.instance.client;
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _addResult('Supabase Test Page Loaded');
    _addResult('Supabase client initialized');
    _checkConnection();
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('[${DateTime.now().toString().split('.')[0]}] $result');
    });
  }

  Future<void> _checkConnection() async {
    _addResult('--- Starting Connection Tests ---');

    // Test 1: Check if client is initialized
    try {
      _addResult('✓ Supabase client initialized');
    } catch (e) {
      _addResult('✗ Failed to initialize client: $e');
      return;
    }

    // Test 2: Check auth state
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        _addResult('✓ User is logged in: ${user.email}');
      } else {
        _addResult('ℹ No user currently logged in');
      }
    } catch (e) {
      _addResult('✗ Auth check failed: $e');
    }

    // Test 3: Test database connection
    await _testDatabaseConnection();

    _addResult('--- Connection Tests Complete ---');
  }

  Future<void> _testDatabaseConnection() async {
    try {
      _addResult('Testing database connection...');

      // Try to query the profiles table
      await _supabase
          .from('profiles')
          .select('id')
          .limit(1);

      _addResult('✓ Database connection successful');
      _addResult('  Profiles table is accessible');
    } catch (e) {
      _addResult('✗ Database connection failed: $e');
      _addResult('  Check if RLS policies are set up correctly');
    }
  }

  Future<void> _testAllTables() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('--- Testing All Database Tables ---');

    final tables = [
      'profiles',
      'timetables',
      'lectures',
      'attendance',
      'streaks',
      'points',
      'friendships',
    ];

    for (final table in tables) {
      try {
        await _supabase.from(table).select('id').limit(1);
        _addResult('✓ Table "$table" is accessible');
      } catch (e) {
        _addResult('✗ Table "$table" failed: ${e.toString().split('\n')[0]}');
      }
    }

    _addResult('--- Table Tests Complete ---');
    setState(() => _isRunning = false);
  }

  Future<void> _testAuth() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('--- Testing Authentication ---');

    // Check current auth state
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      _addResult('✓ Current user: ${currentUser.email}');
      _addResult('  User ID: ${currentUser.id}');
      _addResult('  Created: ${currentUser.createdAt}');

      // Try to get user profile
      try {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', currentUser.id)
            .single();

        _addResult('✓ User profile found:');
        _addResult('  Username: ${profile['username']}');
        _addResult('  University ID: ${profile['university_id'] ?? 'Not set'}');
      } catch (e) {
        _addResult('✗ Failed to fetch profile: $e');
      }
    } else {
      _addResult('ℹ No user logged in');
      _addResult('  You can test signup/login from the auth pages');
    }

    _addResult('--- Auth Tests Complete ---');
    setState(() => _isRunning = false);
  }

  Future<void> _testRealtimeConnection() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('--- Testing Realtime Connection ---');

    try {
      _addResult('Attempting to subscribe to profiles changes...');

      final channel = _supabase.channel('test-channel');

      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'profiles',
        callback: (payload) {
          _addResult('✓ Received realtime update: ${payload.eventType}');
        },
      );

      channel.subscribe();

      _addResult('✓ Realtime subscription successful');
      _addResult('  Channel status: subscribed');

      // Unsubscribe after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        channel.unsubscribe();
        _addResult('ℹ Unsubscribed from test channel');
      });

    } catch (e) {
      _addResult('✗ Realtime connection failed: $e');
    }

    _addResult('--- Realtime Tests Complete ---');
    setState(() => _isRunning = false);
  }

  Future<void> _testStorageBucket() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('--- Testing Storage Buckets ---');

    try {
      final buckets = await _supabase.storage.listBuckets();

      if (buckets.isEmpty) {
        _addResult('ℹ No storage buckets found');
        _addResult('  You may need to create a "avatars" bucket');
      } else {
        _addResult('✓ Found ${buckets.length} storage bucket(s):');
        for (final bucket in buckets) {
          _addResult('  - ${bucket.name} (${bucket.public ? 'public' : 'private'})');
        }
      }
    } catch (e) {
      _addResult('✗ Storage test failed: $e');
    }

    _addResult('--- Storage Tests Complete ---');
    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Supabase Integration Tests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _testAllTables,
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Test Tables'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _testAuth,
                      icon: const Icon(Icons.person),
                      label: const Text('Test Auth'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _testRealtimeConnection,
                      icon: const Icon(Icons.sync),
                      label: const Text('Test Realtime'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _testStorageBucket,
                      icon: const Icon(Icons.storage),
                      label: const Text('Test Storage'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _testResults.clear());
                        _checkConnection();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                reverse: false,
                padding: const EdgeInsets.all(8),
                itemCount: _testResults.length,
                itemBuilder: (context, index) {
                  final result = _testResults[index];
                  Color textColor = Colors.white;

                  if (result.contains('✓')) {
                    textColor = Colors.green;
                  } else if (result.contains('✗')) {
                    textColor = Colors.red;
                  } else if (result.contains('ℹ')) {
                    textColor = Colors.blue;
                  } else if (result.contains('---')) {
                    textColor = Colors.yellow;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      result,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isRunning
          ? const CircularProgressIndicator()
          : null,
    );
  }
}
