import 'package:equatable/equatable.dart';
import '../../domain/models/auth_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Uygulama başlatılıyor — oturum kontrolü yapılıyor.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Oturum kontrol ediliyor.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Kullanıcı giriş yaptı veya mevcut oturumu doğrulandı.
class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Kullanıcı giriş yapmamış veya oturum süresi dolmuş.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Giriş/çıkış işlemi devam ediyor.
class AuthActionLoading extends AuthState {
  const AuthActionLoading();
}

/// Hata oluştu.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Şifre sıfırlama OTP gönderildi.
class AuthForgotPasswordOtpSent extends AuthState {
  final String identifier;
  const AuthForgotPasswordOtpSent(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

/// OTP doğrulandı — yeni şifre ekranına geçilebilir.
class AuthOtpVerified extends AuthState {
  final String phone;
  const AuthOtpVerified(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Şifre başarıyla sıfırlandı.
class AuthPasswordReset extends AuthState {
  const AuthPasswordReset();
}
