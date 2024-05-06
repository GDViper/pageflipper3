import 'package:shared_preferences/shared_preferences.dart';

const ip = '192.168.0.103';

class SettingsManager {
  static SharedPreferences? _preferences;

  static const _keyThemeMode = 'themeMode';
  static const _keyEmail = 'email';
  static const _keyIsbn = 'isbn';

  static Future initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setThemeMode(String themeMode) async {
    await _preferences?.setString(_keyThemeMode, themeMode);
  }

  static String? getThemeMode() {
    return _preferences?.getString(_keyThemeMode) ?? 'system';
  }

  static Future setEmail(String email) async {
    await _preferences?.setString(_keyEmail, email);
  }

  static String? getEmail() {
    return _preferences?.getString(_keyEmail);
  }

  static Future setIsbn(String isbn) async {
    await _preferences?.setString(_keyIsbn, isbn);
  }

  static String? getIsbn() {
    return _preferences?.getString(_keyIsbn);
  }
}
