import 'package:flutter/foundation.dart';
import '../repositories/friends_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../models/models.dart';

class FriendsProvider extends ChangeNotifier {
  final _friendsRepo = FriendsRepository.instance;
  final _leaderboardRepo = LeaderboardRepository.instance;

  List<FriendWithStats> _friends = [];
  List<FriendRequest> _requests = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _showGlobal = true;
  LeaderboardCategory _category = LeaderboardCategory.totalPoints;
  bool _isLoading = false;
  String? _error;

  List<FriendWithStats> get friends => _friends;
  List<FriendRequest> get requests => _requests;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get showGlobal => _showGlobal;
  LeaderboardCategory get category => _category;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _friendsRepo.getFriends();
      _requests = await _friendsRepo.getPendingRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _leaderboard = await _leaderboardRepo.getLeaderboard(
        category: _category,
        global: _showGlobal,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleLeaderboardType() {
    _showGlobal = !_showGlobal;
    loadLeaderboard();
  }

  void setCategory(LeaderboardCategory category) {
    if (_category == category) return;
    _category = category;
    loadLeaderboard();
  }

  Future<void> sendRequest(String userId) async {
    try {
      await _friendsRepo.sendRequest(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String friendshipId) async {
    await _friendsRepo.acceptRequest(friendshipId);
    await loadFriends();
  }

  Future<void> rejectRequest(String friendshipId) async {
    await _friendsRepo.rejectRequest(friendshipId);
    _requests.removeWhere((r) => r.id == friendshipId);
    notifyListeners();
  }

  Future<void> removeFriend(String friendshipId) async {
    await _friendsRepo.removeFriend(friendshipId);
    _friends.removeWhere((f) => f.friendshipId == friendshipId);
    notifyListeners();
  }
}