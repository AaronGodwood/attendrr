import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendr/theme/theme_extensions.dart';
import 'package:attendr/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TerraThemeExtension factories/copy/lerp', () {
    final dark = TerraThemeExtension.dark();
    final light = TerraThemeExtension.light();
    final copied = dark.copyWith(accent: Colors.pink);
    final lerped = dark.lerp(light, 0.5);

    expect(copied.accent, Colors.pink);
    expect(lerped.accent, isNotNull);
    expect(dark.moduleColors, isNotEmpty);
    expect(light.streakGradient.colors, isNotEmpty);
  });

  test('ThemeProvider mode labels and persistence paths', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider();

    await provider.setThemeMode(AppThemeMode.light);
    expect(provider.themeMode, ThemeMode.light);
    expect(provider.themeModeLabel, 'Light');

    await provider.setThemeMode(AppThemeMode.dark);
    expect(provider.themeMode, ThemeMode.dark);
    expect(provider.themeModeLabel, 'Dark');

    await provider.setThemeMode(AppThemeMode.highContrast);
    expect(provider.useHighContrast, isTrue);
    expect(provider.themeMode, ThemeMode.light);
    expect(provider.themeModeLabel, 'High Contrast');

    await provider.setThemeMode(AppThemeMode.system);
    expect(provider.themeMode, ThemeMode.system);
    expect(provider.themeModeLabel, 'System default');
  });
}
