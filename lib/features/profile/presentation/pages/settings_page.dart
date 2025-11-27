import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  int _reminderMinutes = 15;
  bool _appLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _reminderMinutes = prefs.getInt('reminder_time_minutes') ?? 15;
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('reminder_time_minutes', _reminderMinutes);
    await prefs.setBool('app_lock_enabled', _appLockEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Account',
            children: [
              ListTile(
                title: const Text('Email'),
                subtitle: const Text('john.doe@university.edu'),
                trailing: const Icon(Icons.lock_outline, size: 20),
              ),
              ListTile(
                title: const Text('Username'),
                subtitle: const Text('johndoe'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditUsernameDialog(),
              ),
              ListTile(
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(),
              ),
              ListTile(
                title: const Text('Link Timetable'),
                subtitle: const Text('University timetable integration'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            title: 'Appearance',
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_getThemeText()),
                trailing: DropdownButton<ThemeMode>(
                  value: _themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _themeMode = value);
                    }
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Lecture Reminders'),
                subtitle: const Text('Get notified before lectures'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSettings();
                },
              ),
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text('$_reminderMinutes minutes before lecture'),
                enabled: _notificationsEnabled,
                trailing: DropdownButton<int>(
                  value: _reminderMinutes,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 min')),
                    DropdownMenuItem(value: 10, child: Text('10 min')),
                    DropdownMenuItem(value: 15, child: Text('15 min')),
                    DropdownMenuItem(value: 30, child: Text('30 min')),
                  ],
                  onChanged: _notificationsEnabled
                      ? (value) {
                          if (value != null) {
                            setState(() => _reminderMinutes = value);
                            _saveSettings();
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'App Lock',
            children: [
              SwitchListTile(
                title: const Text('Enable App Locking'),
                subtitle: const Text('Lock distracting apps during lectures'),
                value: _appLockEnabled,
                onChanged: (value) {
                  setState(() => _appLockEnabled = value);
                  _saveSettings();
                },
              ),
              if (_appLockEnabled)
                ListTile(
                  title: const Text('Manage Allowed Apps'),
                  subtitle: const Text('3 apps allowed'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAppSelector(),
                ),
            ],
          ),
          _buildSection(
            title: 'Danger Zone',
            children: [
              ListTile(
                title: const Text('Clear Cache'),
                trailing: const Icon(Icons.delete_outline),
                onTap: () => _showClearCacheDialog(),
              ),
              ListTile(
                title: const Text('Sign Out'),
                textColor: Colors.orange,
                trailing: const Icon(Icons.logout, color: Colors.orange),
                onTap: () => _showSignOutDialog(),
              ),
              ListTile(
                title: const Text('Delete Account'),
                textColor: Colors.red,
                trailing: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getThemeText() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showEditUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'New Username',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showAppSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allowed Apps'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              CheckboxListTile(
                title: const Text('Notes'),
                value: true,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Calculator'),
                value: true,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Canvas'),
                value: true,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Instagram'),
                value: false,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('TikTok'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Sign out logic here
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
