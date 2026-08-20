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
        // Production API'sine bağlanıyoruz — web ile aynı veritabanı burada.
        // Yerel test için: 'http://10.0.2.2:8000/api/v1' (local Django sunucu)
        return 'https://siteyonetimi.argeyazilim.tr/api/v1';
      case AppEnv.staging:
        return 'https://staging.example.com/api/v1';
      case AppEnv.production:
        return 'https://siteyonetimi.argeyazilim.tr/api/v1';
    }
  }

  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
  static Duration get sendTimeout => const Duration(seconds: 60);

  /// Mock veri kaynağını etkinleştirir.
  /// false: Gerçek backend API kullanılır.
  /// true : Mock veri kullanılır (backend hazır olmadığında).
  static bool get useMock => _current == AppEnv.development && _forceMock;
  static bool _forceMock = false; // ← BACKEND ENTEGRASYONU BAŞLADI

  static void enableMock() => _forceMock = true;
  static void disableMock() => _forceMock = false;
}
