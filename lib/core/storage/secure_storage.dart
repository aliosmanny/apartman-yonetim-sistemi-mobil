import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT token'larını cihazın güvenli deposunda saklar.
/// Android Keystore / iOS Keychain kullanır.
class SecureStorage {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserRole = 'user_role';
  static const _keyUserId = 'user_id';

  final FlutterSecureStorage _storage;

  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  // ── Access Token ───────────────────────────────
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  // ── Refresh Token ──────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.read(key: _keyRefreshToken).then((_) =>
          _storage.write(key: _keyRefreshToken, value: token));

  Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  // ── Kullanıcı Bilgileri ────────────────────────
  Future<void> saveUserRole(String role) =>
      _storage.write(key: _keyUserRole, value: role);

  Future<String?> getUserRole() =>
      _storage.read(key: _keyUserRole);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  Future<String?> getUserId() =>
      _storage.read(key: _keyUserId);

  // ── Oturum kaydetme (hepsini birden) ──────────
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyUserRole, value: role),
      _storage.write(key: _keyUserId, value: userId),
    ]);
  }

  // ── Oturumu temizleme ─────────────────────────
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserRole),
      _storage.delete(key: _keyUserId),
    ]);
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
