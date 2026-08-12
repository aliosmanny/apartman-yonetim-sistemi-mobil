import 'package:dio/dio.dart';
import '../config/app_environment.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage.dart';

/// Merkezi Dio HTTP istemcisi.
/// Tüm API istekleri bu instance üzerinden yapılır.
class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.baseUrl,
        connectTimeout: AppEnvironment.connectTimeout,
        receiveTimeout: AppEnvironment.receiveTimeout,
        sendTimeout: AppEnvironment.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_dio, _secureStorage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _log(obj.toString()),
      ),
    ]);
  }

  Dio get dio => _dio;

  void _log(String message) {
    // Production'da log gösterilmez
    if (AppEnvironment.current == AppEnv.development) {
      // ignore: avoid_print
      print('[API] $message');
    }
  }

  /// Base URL'i günceller (ortam değiştiğinde).
  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
}
