import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String username;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use a different provider or method for fetching other users' profiles
      // For now, this will just load the current user's profile
      // context.read<ProfileProvider>().loadProfile(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.username)),
      body: Center(child: Text('Profile of ${widget.username}')),
    );
  }
}
