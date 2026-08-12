import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcı tercihlerini ve hassas olmayan verileri saklar.
class LocalStorage {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLanguage = 'language';
  static const _keyNotificationsEnabled = 'notifications_enabled';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // ── Onboarding ────────────────────────────────
  bool get onboardingSeen => _prefs.getBool(_keyOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen() => _prefs.setBool(_keyOnboardingSeen, true);

  // ── Tema ─────────────────────────────────────
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'light';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // ── Dil ──────────────────────────────────────
  String get language => _prefs.getString(_keyLanguage) ?? 'tr';
  Future<void> setLanguage(String lang) => _prefs.setString(_keyLanguage, lang);

  // ── Bildirimler ───────────────────────────────
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotificationsEnabled, value);

  // ── Genel ────────────────────────────────────
  Future<void> clear() => _prefs.clear();
}
