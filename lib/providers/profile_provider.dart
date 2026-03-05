import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/shop_repository.dart';
import '../models/models.dart';

class ProfileProvider extends ChangeNotifier {
  final _userRepo = UserRepository.instance;
  final _attendanceRepo = AttendanceRepository.instance;
  final _shopRepo = ShopRepository.instance;

  User? _user;
  Streak? _streak;
  Points? _points;
  AttendanceStats? _stats;
  List<DailyAttendance>? _history;
  StreakEvaluation? _lastEvaluation;
  String? _milestoneRewardMessage;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;

  User? get user => _user;
  Streak? get streak => _streak;
  Points? get points => _points;
  AttendanceStats? get stats => _stats;
  List<DailyAttendance>? get history => _history;
  StreakEvaluation? get lastEvaluation => _lastEvaluation;
  String? get milestoneRewardMessage => _milestoneRewardMessage;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Evaluate streak first (handles missed days, consumes freezes)
      _lastEvaluation = await _userRepo.evaluateStreak();

      final profile = await _userRepo.getFullProfile();
      _user = profile.user;
      _streak = profile.streak;
      _points = profile.points;
      await _applyTierMilestoneRewards();
      _stats = await _attendanceRepo.getStats();
      await applyWeeklyPerfectAttendanceReward();
      _history = await _attendanceRepo.getHistory(30);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUsername(String username) async {
    try {
      await _userRepo.updateProfile(username: username);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAvatar(XFile imageFile) async {
    _isUploading = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name.isNotEmpty ? imageFile.name : imageFile.path;
      final ext = filename.contains('.') ? filename.split('.').last : 'jpg';
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = client.storage.from('avatars').getPublicUrl(path);
      await _userRepo.updateProfile(avatarUrl: publicUrl);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> removeAvatar() async {
    _isUploading = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      await client
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', client.auth.currentUser!.id);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearEvaluation() {
    _lastEvaluation = null;
  }

  void clearMilestoneRewardMessage() {
    _milestoneRewardMessage = null;
  }

  Future<void> refresh() => loadProfile();

  Future<void> _applyTierMilestoneRewards() async {
    final user = _user;
    final points = _points;
    if (user == null || points == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'claimed_tier_rewards_${user.id}';
    final claimedIndexes =
        (prefs.getStringList(key) ?? [])
            .map(int.tryParse)
            .whereType<int>()
            .toSet();

    final granted = <String>[];
    for (int tierIndex = 1; tierIndex <= points.tier.index; tierIndex++) {
      if (claimedIndexes.contains(tierIndex)) continue;
      final tier = PointsTier.values[tierIndex];
      final rewardType =
          tier.index <= PointsTier.intermediate.index
              ? ShopItemType.streakFreeze
              : ShopItemType.weeklyPointsBoost;
      final success = await _shopRepo.grantMilestoneReward(rewardType);
      if (success) {
        claimedIndexes.add(tierIndex);
        granted.add(rewardType.label);
      }
    }

    if (granted.isNotEmpty) {
      await prefs.setStringList(
        key,
        claimedIndexes.map((i) => i.toString()).toList(),
      );
      _appendRewardMessage('Level-up reward unlocked: ${granted.join(', ')}');
    }
  }

  Future<void> applyWeeklyPerfectAttendanceReward() async {
    final user = _user;
    final stats = _stats;
    if (user == null || stats == null) return;
    if (!isWeeklyPerfectAttendance(stats)) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'claimed_perfect_weeks_${user.id}';
    final claimedWeeks = (prefs.getStringList(key) ?? []).toSet();
    final currentWeek = weekKey(DateTime.now());
    if (claimedWeeks.contains(currentWeek)) return;

    final success = await _shopRepo.grantMilestoneReward(
      ShopItemType.streakFreeze,
    );
    if (!success) return;

    claimedWeeks.add(currentWeek);
    await prefs.setStringList(key, claimedWeeks.toList());
    _appendRewardMessage(
      'Perfect attendance reward: ${ShopItemType.streakFreeze.label}',
    );
  }

  @visibleForTesting
  static bool isWeeklyPerfectAttendance(AttendanceStats stats) {
    return stats.weeklyTotal > 0 && stats.weeklyAttended == stats.weeklyTotal;
  }

  @visibleForTesting
  static String weekKey(DateTime date) {
    final monday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
    final mm = monday.month.toString().padLeft(2, '0');
    final dd = monday.day.toString().padLeft(2, '0');
    return '${monday.year}-$mm-$dd';
  }

  void _appendRewardMessage(String message) {
    if (_milestoneRewardMessage == null || _milestoneRewardMessage!.isEmpty) {
      _milestoneRewardMessage = message;
      return;
    }
    _milestoneRewardMessage = '${_milestoneRewardMessage!}\n$message';
  }
}
