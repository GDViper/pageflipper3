import 'package:shared_preferences/shared_preferences.dart';

const ip = '192.168.0.103';

class SettingsManager {
  static SharedPreferences? _preferences;

  static const _keyThemeMode = 'themeMode';
  static const _keyUsername = 'username';

  static Future initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setThemeMode(String themeMode) async {
    await _preferences?.setString(_keyThemeMode, themeMode);
  }

  static String? getThemeMode() {
    return _preferences?.getString(_keyThemeMode) ?? 'system';
  }

  static Future setUsername(String username) async {
    await _preferences?.setString(_keyUsername, username);
  }

  static String? getUsername() {
    return _preferences?.getString(_keyUsername);
  }
}
