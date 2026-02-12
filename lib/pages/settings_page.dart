import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../theme/theme_extensions.dart';
import '../utils/constants.dart';
import '../widgets/settings/ical_setup_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _isLoadingNotificationPreference = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(StorageKeys.notificationsEnabled) ?? false;

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _isLoadingNotificationPreference = false;
    });
  }

  Future<void> _onNotificationsToggled(bool enabled) async {
    try {
      if (kIsWeb) {
        return;
      }

      if (enabled) {
        await NotificationService.instance.initialize();
        final granted = await NotificationService.instance.requestPermissions();
        if (!granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notification permission denied. Enable it in system settings.',
              ),
            ),
          );
          return;
        }
      } else {
        await NotificationService.instance.cancelAll();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.notificationsEnabled, enabled);

      if (!mounted) return;
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update notifications setting.'),
        ),
      );
    }
  }

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
                  onTap:
                      () => _showEditUsernameDialog(
                        context,
                        user?.username ?? '',
                      ),
                ),
                ListTile(
                  title: const Text('Link Google Account'),
                  subtitle: Text(
                    _isGoogleLinked(context.read<AuthProvider>().user)
                        ? 'Linked'
                        : 'Sign in with Google',
                  ),
                  trailing: Icon(
                    _isGoogleLinked(context.read<AuthProvider>().user)
                        ? Icons.check_circle
                        : Icons.link,
                  ),
                  onTap:
                      _isGoogleLinked(context.read<AuthProvider>().user)
                          ? null
                          : () => _linkGoogleAccount(context),
                ),
                ListTile(
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                ListTile(
                  title: const Text('Link Timetable'),
                  subtitle: Text(
                    user?.hasIcalConnected == true
                        ? 'Connected • Tap to update'
                        : 'Import from university calendar',
                  ),
                  leading: const Icon(Icons.calendar_month),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showIcalSetup(context, user?.icalUrl),
                ),
              ], context),

              _buildSection('App', [
                ListTile(
                  title: const Text('Notifications'),
                  subtitle: Text(
                    kIsWeb
                        ? 'Not supported on web'
                        : _notificationsEnabled
                        ? 'Lecture reminders enabled'
                        : 'Lecture reminders disabled',
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged:
                        (kIsWeb || _isLoadingNotificationPreference)
                            ? null
                            : _onNotificationsToggled,
                  ),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return ListTile(
                      title: const Text('Theme'),
                      subtitle: Text(themeProvider.themeModeLabel),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeDialog(context),
                    );
                  },
                ),
              ], context),

              _buildSection('Account Actions', [
                ListTile(
                  title: const Text('Sign Out'),
                  leading: Icon(
                    Icons.logout,
                    color:
                        Theme.of(
                          context,
                        ).extension<TerraThemeExtension>()?.danger,
                  ),
                  onTap: () => _handleSignOut(context),
                ),
              ], context),
            ],
          );
        },
      ),
    );
  }

  bool _isGoogleLinked(User? user) {
    final identities = user?.identities;
    if (identities == null) return false;
    return identities.any((identity) => identity.provider == 'google');
  }

  Future<void> _linkGoogleAccount(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.linkGoogleIdentity();
    if (!mounted) return;
    if (!success && authProvider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authProvider.error!)));
    }
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: ext?.textSecondary,
            ),
          ),
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
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Username'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<ProfileProvider>().updateUsername(
                    controller.text,
                  );
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

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('System default'),
                  subtitle: const Text('Follow device settings'),
                  leading: Radio<AppThemeMode>(
                    value: AppThemeMode.system,
                    groupValue: themeProvider.appThemeMode,
                    onChanged: null,
                  ),
                  onTap: () {
                    themeProvider.setThemeMode(AppThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Light'),
                  subtitle: const Text('Always use light theme'),
                  leading: Radio<AppThemeMode>(
                    value: AppThemeMode.light,
                    groupValue: themeProvider.appThemeMode,
                    onChanged: null,
                  ),
                  onTap: () {
                    themeProvider.setThemeMode(AppThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Dark'),
                  subtitle: const Text('Always use dark theme'),
                  leading: Radio<AppThemeMode>(
                    value: AppThemeMode.dark,
                    groupValue: themeProvider.appThemeMode,
                    onChanged: null,
                  ),
                  onTap: () {
                    themeProvider.setThemeMode(AppThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('High Contrast'),
                  subtitle: const Text(
                    'Accessibility theme with high contrast',
                  ),
                  leading: Radio<AppThemeMode>(
                    value: AppThemeMode.highContrast,
                    groupValue: themeProvider.appThemeMode,
                    onChanged: null,
                  ),
                  onTap: () {
                    themeProvider.setThemeMode(AppThemeMode.highContrast);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        bool obscureNew = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Change Password'),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () => obscureConfirm = !obscureConfirm,
                                ),
                          ),
                        ),
                        validator: (value) {
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              if (!formKey.currentState!.validate()) return;
                              setState(() => isLoading = true);
                              final success = await context
                                  .read<AuthProvider>()
                                  .updatePassword(newPasswordController.text);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Password updated successfully'
                                          : 'Failed to update password',
                                    ),
                                  ),
                                );
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Save'),
                  ),
                ],
              ),
        );
      },
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(
                        context,
                      ).extension<TerraThemeExtension>()?.danger,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}
