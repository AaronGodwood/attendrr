import 'package:flutter/material.dart';

class GamificationProvider extends ChangeNotifier {
  int _currentStreak = 12;
  int _totalPoints = 450;
  int _streakFreezes = 2;

  int get currentStreak => _currentStreak;
  int get totalPoints => _totalPoints;
  int get streakFreezes => _streakFreezes;

  // Template methods for gamification
  void addPoints(int points) {
    _totalPoints += points;
    notifyListeners();
  }

  void incrementStreak() {
    _currentStreak++;
    notifyListeners();
  }

  void useStreakFreeze() {
    if (_streakFreezes > 0) {
      _streakFreezes--;
      notifyListeners();
    }
  }
}
