import '../models/auth_user.dart';

/// Auth repository sözleşmesi.
/// Ekran katmanı yalnızca bu arayüzü bilir — mock mu remote mu olduğunu bilmez.
abstract class AuthRepository {
  /// Telefon + şifre ile giriş yapar.
  /// Başarılı olursa [AuthUser] döner, token'ları depolar.
  Future<AuthUser> login({
    required String phone,
    required String password,
  });

  /// Refresh token'ı blacklist'e ekler, depolanmış token'ları siler.
  Future<void> logout();

  /// Depoda kayıtlı oturum varsa [AuthUser] döner, yoksa null.
  Future<AuthUser?> getStoredUser();

  /// Şifre sıfırlama için OTP gönderir.
  Future<void> sendForgotPasswordOtp({required String identifier});

  /// OTP kodunu doğrular.
  Future<void> verifyForgotPasswordOtp({
    required String phone,
    required String code,
  });

  /// Yeni şifreyi belirler.
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirm,
  });
}
