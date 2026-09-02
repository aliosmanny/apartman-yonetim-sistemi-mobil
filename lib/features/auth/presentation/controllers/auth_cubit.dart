import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import 'auth_state.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../users/presentation/controllers/user_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../users/domain/repositories/user_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthInitial());

  /// Uygulama açıldığında mevcut oturumu kontrol eder.
  Future<void> checkSession() async {
    emit(const AuthLoading());
    try {
      final user = await _repository.getStoredUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        _sendDeviceToken();
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Telefon + şifre ile giriş.
  Future<void> login({required String phone, required String password}) async {
    emit(const AuthActionLoading());
    try {
      final user = await _repository.login(phone: phone, password: password);
      emit(AuthAuthenticated(user));
      _sendDeviceToken();
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } on ValidationFailure catch (e) {
      emit(AuthError(e.message));
    } on NetworkFailure catch (e) {
      emit(AuthError(e.message));
    } on UnauthorizedFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Giriş sırasında bir hata oluştu.'));
    }
  }

  /// TODO: firebase_messaging paketi projeye dahil edildiğinde
  /// 'FirebaseMessaging.instance.getToken()' ile gerçek token alınacak.
  void _sendDeviceToken() async {
    try {
      final deviceType = Platform.isIOS ? 'ios' : 'android';
      // firebase_messaging kurulana kadar geçici (mock) token yolluyoruz ki backend testi patlamasın.
      final mockToken =
          'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      await sl<UserRepository>().saveDeviceToken(mockToken, deviceType);
    } catch (e) {
      // Token hatası uygulamanın çalışmasını durdurmamalı
    }
  }

  /// Oturumu kapat.
  Future<void> logout() async {
    emit(const AuthActionLoading());
    try {
      await _repository.logout();
      // Oturum kapatıldığında statik önbellekleri temizle
      PropertiesCubit.clearCache();
      FinanceCubit.clearCache();
      UserCubit.clearCache();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  /// Şifre sıfırlama — OTP gönder.
  Future<void> sendForgotPasswordOtp({required String identifier}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.sendForgotPasswordOtp(identifier: identifier);
      emit(AuthForgotPasswordOtpSent(identifier));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('OTP gönderilemedi. Lütfen tekrar deneyin.'));
    }
  }

  /// OTP kodu doğrula.
  Future<void> verifyOtp({required String phone, required String code}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.verifyForgotPasswordOtp(phone: phone, code: code);
      emit(AuthOtpVerified(phone));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Kod doğrulanamadı. Lütfen tekrar deneyin.'));
    }
  }

  /// Yeni şifre belirle.
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirm,
  }) async {
    emit(const AuthActionLoading());
    try {
      await _repository.resetPassword(
        phone: phone,
        code: code,
        password: password,
        passwordConfirm: passwordConfirm,
      );
      emit(const AuthPasswordReset());
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Şifre sıfırlanamadı. Lütfen tekrar deneyin.'));
    }
  }

  void resetState() => emit(const AuthUnauthenticated());

  /// Profil sayfasından şifre değiştir.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // We don't emit AuthActionLoading here because it might reset the whole page state if not handled,
    // but the caller expects to await this Future.
    // Or we could create a new state. Since it's returning a Future, throwing an exception is better for the UI.
    try {
      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on Failure catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('Şifreniz değiştirilemedi.');
    }
  }
}
