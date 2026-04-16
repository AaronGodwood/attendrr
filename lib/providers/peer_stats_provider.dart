import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/friend_repository.dart';
import '../repositories/user_repository.dart';

class UserStats {
  final User user;
  final AttendanceStats stats;
  final Streak streak;

  const UserStats({
    required this.user,
    required this.stats,
    required this.streak,
  });
}

class PeerStatsProvider extends ChangeNotifier {
  final _userRepo = UserRepository.instance;
  final _attendanceRepo = AttendanceRepository.instance;
  final _friendRepo = FriendRepository.instance;

  List<UserStats> _global = [];
  List<UserStats> _friends = [];
  Set<String> _friendIds = {};
  bool _isLoadingGlobal = false;
  bool _isLoadingFriends = false;
  String? _globalError;
  String? _friendsError;

  List<UserStats> get global => _global;
  List<UserStats> get friends => _friends;
  Set<String> get friendIds => _friendIds;
  bool get isLoadingGlobal => _isLoadingGlobal;
  bool get isLoadingFriends => _isLoadingFriends;
  String? get globalError => _globalError;
  String? get friendsError => _friendsError;

  bool isFriend(String userId) => _friendIds.contains(userId);

  Future<void> loadGlobal() async {
    _isLoadingGlobal = true;
    _globalError = null;
    notifyListeners();

    try {
      final users = await _userRepo.getAllUsers();
      _global = await _fetchStatsForUsers(users);
    } catch (e) {
      _globalError = e.toString();
    }

    _isLoadingGlobal = false;
    notifyListeners();
  }

  Future<void> loadFriends() async {
    _isLoadingFriends = true;
    _friendsError = null;
    notifyListeners();

    try {
      _friendIds = (await _friendRepo.getFriendIds()).toSet();
      if (_friendIds.isEmpty) {
        _friends = [];
      } else {
        final users = await Future.wait(
          _friendIds.map((id) => _userRepo.getUserProfile(id)),
        );
        _friends = await _fetchStatsForUsers(users);
      }
    } catch (e) {
      _friendsError = e.toString();
    }

    _isLoadingFriends = false;
    notifyListeners();
  }

  Future<List<UserStats>> _fetchStatsForUsers(List<User> users) async {
    final results = await Future.wait(
      users.map((user) async {
        final stats = await _attendanceRepo.getUserStats(user.id);
        final streak = await _userRepo.getUserStreak(user.id);
        return UserStats(user: user, stats: stats, streak: streak);
      }),
    );
    return results;
  }

  Future<List<User>> searchUsers(String query) =>
      _userRepo.searchUsers(query);

  Future<void> addFriend(String userId) async {
    await _friendRepo.addFriend(userId);
    _friendIds.add(userId);
    notifyListeners();
    await loadFriends();
  }

  Future<void> removeFriend(String userId) async {
    await _friendRepo.removeFriend(userId);
    _friendIds.remove(userId);
    _friends.removeWhere((s) => s.user.id == userId);
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([loadGlobal(), loadFriends()]);
  }
}
