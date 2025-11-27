import 'package:flutter/material.dart';

class FriendsProvider extends ChangeNotifier {
  List<dynamic> _friends = [];
  List<dynamic> _friendRequests = [];

  List<dynamic> get friends => _friends;
  List<dynamic> get friendRequests => _friendRequests;

  Future<void> loadFriends() async {
    // TODO: Implement friends loading
    notifyListeners();
  }

  Future<void> sendFriendRequest(String userId) async {
    // TODO: Implement send friend request
    notifyListeners();
  }

  Future<void> acceptFriendRequest(String requestId) async {
    // TODO: Implement accept friend request
    notifyListeners();
  }
}
