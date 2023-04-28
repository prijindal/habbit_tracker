import 'package:flutter/material.dart';
import 'package:habbit_tracker/helpers/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/constants.dart';

class ThemeModeNotifier with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeModeNotifier(this._themeMode) {
    init();
  }

  init() {
    AppLogger.instance.d("Reading $appThemeMode from shared_preferences");
    SharedPreferences.getInstance().then((instance) {
      final preference = instance.getInt(appThemeMode);
      _themeMode = ThemeMode.values[preference ?? ThemeMode.system.index];
      AppLogger.instance
          .d("Read $appThemeMode as $preference from shared_preferences");
      notifyListeners();
    });
  }

  getTheme() => _themeMode;

  setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    (await SharedPreferences.getInstance()).setInt(
      appThemeMode,
      themeMode.index,
    );
    notifyListeners();
  }
}
