import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Her isteğe Authorization header ekler.
/// Access token süresi dolunca refresh token ile yeniler.
/// Yenileme başarısızsa SecureStorage'ı temizler.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;

  // Refresh beklerken biriken istekler
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _pendingRequests = [];

  AuthInterceptor(this._dio, this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Login, refresh ve kayıt endpoint'leri token gerektirmez
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !_isPublicEndpoint(err.requestOptions.path)) {
      if (_isRefreshing) {
        // Başka bir refresh zaten devam ediyor — isteği sıraya al
        _pendingRequests.add((options: err.requestOptions, handler: handler));
        return;
      }
      await _handleTokenRefresh(err, handler);
    } else {
      handler.next(err);
    }
  }

  Future<void> _handleTokenRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _isRefreshing = true;
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearAndReject(err, handler);
        return;
      }

      final response = await _dio.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ),
      );

      final newAccessToken = response.data['access'] as String?;
      if (newAccessToken == null) {
        await _clearAndReject(err, handler);
        return;
      }

      await _secureStorage.saveAccessToken(newAccessToken);

      // Özgün isteği yeni token ile tekrar gönder
      final retryOptions = Options(
        method: err.requestOptions.method,
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
        contentType: err.requestOptions.contentType,
        responseType: err.requestOptions.responseType,
      );
      final retryResponse = await _dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: retryOptions,
      );
      handler.resolve(retryResponse);

      // Bekleyen istekleri de yeni token ile gönder
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final r = await _dio.fetch(pending.options);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.next(err);
        }
      }
      _pendingRequests.clear();
    } catch (_) {
      await _clearAndReject(err, handler);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clearAndReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _secureStorage.clearSession();
    // Bekleyen istekleri de hata ile bitir
    for (final pending in _pendingRequests) {
      pending.handler.next(err);
    }
    _pendingRequests.clear();
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/auth/login/',
      '/auth/refresh/',
      '/auth/register/',
      '/auth/otp/send/',
      '/auth/otp/verify/',
      '/auth/forgot-password/',
      '/auth/forgot-password/verify/',
      '/auth/forgot-password/reset/',
    ];
    return publicPaths.any((p) => path.endsWith(p));
  }
}
