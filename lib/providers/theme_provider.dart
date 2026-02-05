import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

enum AppThemeMode {
  light,
  dark,
  highContrast,
  system,
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppThemeMode _appThemeMode = AppThemeMode.system;
  bool _useHighContrast = false;

  ThemeMode get themeMode => _useHighContrast ? ThemeMode.light : _themeMode;
  AppThemeMode get appThemeMode => _appThemeMode;
  bool get useHighContrast => _useHighContrast;

  String get themeModeLabel {
    switch (_appThemeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.highContrast:
        return 'High Contrast';
      case AppThemeMode.system:
        return 'System default';
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(StorageKeys.themeMode);

      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            _appThemeMode = AppThemeMode.light;
            _themeMode = ThemeMode.light;
            _useHighContrast = false;
            break;
          case 'dark':
            _appThemeMode = AppThemeMode.dark;
            _themeMode = ThemeMode.dark;
            _useHighContrast = false;
            break;
          case 'highContrast':
            _appThemeMode = AppThemeMode.highContrast;
            _themeMode = ThemeMode.light;
            _useHighContrast = true;
            break;
          case 'system':
            _appThemeMode = AppThemeMode.system;
            _themeMode = ThemeMode.system;
            _useHighContrast = false;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, keep the default ThemeMode.system
      debugPrint('Failed to load theme mode: $e');
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_appThemeMode == mode) return;

    _appThemeMode = mode;

    switch (mode) {
      case AppThemeMode.light:
        _themeMode = ThemeMode.light;
        _useHighContrast = false;
        break;
      case AppThemeMode.dark:
        _themeMode = ThemeMode.dark;
        _useHighContrast = false;
        break;
      case AppThemeMode.highContrast:
        _themeMode = ThemeMode.light;
        _useHighContrast = true;
        break;
      case AppThemeMode.system:
        _themeMode = ThemeMode.system;
        _useHighContrast = false;
        break;
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;

      switch (mode) {
        case AppThemeMode.light:
          modeString = 'light';
          break;
        case AppThemeMode.dark:
          modeString = 'dark';
          break;
        case AppThemeMode.highContrast:
          modeString = 'highContrast';
          break;
        case AppThemeMode.system:
          modeString = 'system';
          break;
      }

      await prefs.setString(StorageKeys.themeMode, modeString);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }
}
