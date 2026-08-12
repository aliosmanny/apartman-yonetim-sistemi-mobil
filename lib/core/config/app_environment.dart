/// Uygulama ortam ayarları.
/// API adresi kaynak kod içine dağınık biçimde yazılmaz — buradan yönetilir.
enum AppEnv { development, staging, production }

abstract class AppEnvironment {
  static AppEnv _current = AppEnv.development;

  static AppEnv get current => _current;

  static void setEnvironment(AppEnv env) {
    _current = env;
  }

  /// Aktif ortamın base URL'ini döner.
  static String get baseUrl {
    switch (_current) {
      case AppEnv.development:
        // TODO(api-contract): Ahmet'ten development sunucu adresi alınacak.
        // Örnek: 'http://192.168.1.100:8000/api/v1'
        return 'http://10.0.2.2:8000/api/v1'; // Android emülatör localhost
      case AppEnv.staging:
        // TODO(api-contract): Staging sunucu adresi alınacak.
        return 'https://staging.example.com/api/v1';
      case AppEnv.production:
        // TODO(api-contract): Production sunucu adresi alınacak.
        return 'https://siteyonetimi.argeyazilim.tr/api/v1';
    }
  }

  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
  static Duration get sendTimeout => const Duration(seconds: 60);

  /// Mock veri kaynağını etkinleştirir.
  /// Backend erişilemediğinde geliştirme için kullanılır.
  static bool get useMock => _current == AppEnv.development && _forceMock;
  static bool _forceMock = true;

  static void enableMock() => _forceMock = true;
  static void disableMock() => _forceMock = false;
}
