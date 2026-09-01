import 'package:dio/dio.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';
import '../../../../core/network/api_exception.dart';

/// Gerçek Django REST API'ye bağlanan veri kaynağı.
/// Backend: apps/api/views_auth.py → LoginView
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  /// POST /api/v1/auth/login/
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: request.toJson(),
      );
      return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/logout/
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        '/auth/logout/',
        data: {'refresh': refreshToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/forgot-password/
  Future<void> sendForgotPasswordOtp({required String identifier}) async {
    try {
      await _dio.post(
        '/auth/forgot-password/',
        data: {'identifier': identifier, 'method': 'sms'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/forgot-password/verify/
  Future<void> verifyForgotPasswordOtp({
    required String phone,
    required String code,
  }) async {
    try {
      await _dio.post(
        '/auth/forgot-password/verify/',
        data: {'phone': phone, 'code': code},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/forgot-password/reset/
  /// TODO(api-contract): Verify sonrası reset token akışı backend'de tamamlanınca güncellenir.
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      await _dio.post(
        '/auth/forgot-password/reset/',
        data: {
          'phone': phone,
          'code': code,
          'password': password,
          'password_confirm': passwordConfirm,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /api/v1/profile/change-password/
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/profile/change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
