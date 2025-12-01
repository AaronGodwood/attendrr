import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/settings/ical_setup_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          final user = profile.user;

          return ListView(
            children: [
              _buildSection('Account', [
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? 'Not set'),
                  trailing: const Icon(Icons.lock_outline, size: 20),
                ),
                ListTile(
                  title: const Text('Username'),
                  subtitle: Text(user?.username ?? 'Not set'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditUsernameDialog(context, user?.username ?? ''),
                ),
                ListTile(
                  title: const Text('Link Timetable'),
                  subtitle: Text(user?.hasIcalConnected == true ? 'Connected • Tap to update' : 'Import from university calendar'),
                  leading: const Icon(Icons.calendar_month),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showIcalSetup(context, user?.icalUrl),
                ),
              ]),

              _buildSection('App', [
                ListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Lecture reminders'),
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                ListTile(
                  title: const Text('Theme'),
                  subtitle: const Text('System default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ]),

              _buildSection('Account Actions', [
                ListTile(
                  title: const Text('Sign Out'),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onTap: () => _handleSignOut(context),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showEditUsernameDialog(BuildContext context, String currentUsername) {
    final controller = TextEditingController(text: currentUsername);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<ProfileProvider>().updateUsername(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showIcalSetup(BuildContext context, String? currentUrl) {
    showDialog(
      context: context,
      builder: (context) => ICalSetupDialog(currentUrl: currentUrl),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}