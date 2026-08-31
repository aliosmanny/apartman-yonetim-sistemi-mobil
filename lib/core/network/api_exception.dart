import 'package:dio/dio.dart';
import '../errors/failures.dart';

/// Dio response'larından parse edilen API hatası.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  /// DioException'dan ApiException üretir.
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Bağlantı zaman aşımına uğradı.');

      case DioExceptionType.connectionError:
        return const ApiException(message: 'İnternet bağlantısı yok. Lütfen kontrol edin.');

      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final statusCode = e.response?.statusCode;
        String message = _extractMessage(data, statusCode);
        final fieldErrors = _extractFieldErrors(data);
        return ApiException(
          message: message,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
        );

      case DioExceptionType.cancel:
        return const ApiException(message: 'İstek iptal edildi.');

      default:
        return const ApiException(message: 'Beklenmeyen bir hata oluştu.');
    }
  }

  static String _extractMessage(dynamic data, int? statusCode) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null) return data['message'].toString();
      if (data.containsKey('detail') && data['detail'] != null) return data['detail'].toString();
      if (data.containsKey('non_field_errors')) {
        final errors = data['non_field_errors'];
        if (errors is List && errors.isNotEmpty) return errors.first.toString();
      }
      
      // For DRF: collect all string list values from the map if they look like errors
      final errorFields = <String>[];
      data.forEach((key, value) {
        if (key != 'message' && key != 'detail' && key != 'non_field_errors') {
          if (value is List && value.isNotEmpty) {
            errorFields.add('$key: ${value.join(", ")}');
          } else if (value is String) {
            errorFields.add('$key: $value');
          }
        }
      });
      if (errorFields.isNotEmpty) {
        return errorFields.join('\n');
      }
    }
    switch (statusCode) {
      case 400:
        return 'Girilen bilgiler geçersiz.';
      case 401:
        return 'Oturumunuz sonlandı. Lütfen tekrar giriş yapın.';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 404:
        return 'Kayıt bulunamadı.';
      case 422:
        return 'Gönderilen veriler geçersiz.';
      case 500:
      case 502:
      case 503:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    final result = <String, List<String>>{};
    errors.forEach((key, value) {
      if (value is List) {
        result[key] = value.map((e) => e.toString()).toList();
      }
    });
    return result.isEmpty ? null : result;
  }

  /// ApiException → Failure dönüşümü.
  Failure toFailure() {
    switch (statusCode) {
      case 401:
        // Backend'den gelen gerçek mesajı kullan (örn: "yanlış şifre" vs "oturum sona erdi")
        return UnauthorizedFailure(message);
      case 403:
        return const ForbiddenFailure();
      case 404:
        return NotFoundFailure(message);
      case 400:
      case 422:
        return ValidationFailure(message, fieldErrors: fieldErrors);
      case null:
        if (message.contains('İnternet') || message.contains('bağlantı')) {
          return const NetworkFailure();
        }
        return UnexpectedFailure(message);
      default:
        return ServerFailure(message, statusCode: statusCode);
    }
  }

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}
