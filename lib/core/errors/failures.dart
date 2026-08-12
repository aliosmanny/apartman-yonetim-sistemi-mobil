/// Uygulama genelinde hata türleri.
/// Repository katmanı bu Failure'ları döner;
/// ekran katmanı kullanıcıya uygun mesajı gösterir.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// Ağ bağlantısı yok.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'İnternet bağlantısı yok. Lütfen kontrol edin.']);
}

/// Sunucu 4xx/5xx döndü.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// 401 Unauthorized — oturum süresi doldu.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Oturumunuz sonlandı. Lütfen tekrar giriş yapın.']);
}

/// 403 Forbidden — yetki yok.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Bu işlem için yetkiniz bulunmuyor.']);
}

/// 404 Not Found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Kayıt bulunamadı.']);
}

/// Form doğrulama hatası (alan bazlı).
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors});
}

/// Yerel depolama hatası.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Yerel veri okunamadı.']);
}

/// Beklenmeyen hata.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Beklenmeyen bir hata oluştu.']);
}
