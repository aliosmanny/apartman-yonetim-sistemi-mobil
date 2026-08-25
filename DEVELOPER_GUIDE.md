# 🛠️ Apartman Yönetim Sistemi - Geliştirici El Kitabı (Developer Guide)

Bu doküman, projeyi devralacak veya projeye yeni dahil olacak geliştiriciler için sistem mimarisini, klasör yapılarını, tasarım kalıplarını ve teknik detayları açıklamak amacıyla hazırlanmıştır.

---

## 🗺️ Genel Sistem Mimarisi

Sistem, gevşek bağlı (loosely-coupled) iki ana bileşenden oluşmaktadır:
1. **Frontend (Mobil Uygulama):** Flutter SDK ile yazılmış, Clean Architecture prensiplerini kullanan mobil istemci.
2. **Backend (Sunucu/API):** Django ve Django REST Framework (DRF) ile geliştirilmiş, rol bazlı yetkilendirmeye (RBAC) sahip API servis sağlayıcı.

İletişim tamamen **RESTful JSON API** protokolü üzerinden yürütülür.

---

## 📱 1. Mobil Uygulama (Flutter) Mimarisi

Mobil proje, ölçeklenebilirliği sağlamak ve kod karmaşasını önlemek amacıyla **Clean Architecture (Temiz Mimari)** ve **Feature-First (Özellik Odaklı)** yaklaşımları birleştirilerek tasarlanmıştır.

### 📂 Klasör Yapısı (`lib/`)

```directory
lib/
├── app/                  # Uygulama düzeyindeki yapılandırmalar (Tema, Rotalar vb.)
│   ├── router/           # GoRouter deklaratif navigasyon tanımları
│   └── theme/            # Renkler, yazı stilleri ve genel malzeme teması
├── bootstrap.dart        # Uygulama başlatma öncesi loglama ve DI başlatıcı
├── core/                 # Özelliklerden bağımsız ortak çekirdek modüller
│   ├── config/           # Ortam ayarları (Development/Production Base URL'leri)
│   ├── di/               # GetIt Dependency Injection (Servis Kayıtları)
│   ├── errors/           # Hata sınıfları ve Exception tanımları
│   ├── network/          # Dio istemcisi, Auth Interceptor ve loglama
│   └── storage/          # SecureStorage ve SharedPreferences yönetimi
├── features/             # İş özelliklerine göre ayrılmış bağımsız modüller (Dikey Bölümleme)
│   ├── auth/             # Giriş, Kayıt, OTP ve şifre işlemleri
│   ├── dashboard/        # Rol bazlı ana ekranlar (Yönetici, Sakin, Personel)
│   ├── finance/          # Gelir/Gider, Aidatlar, Borçlar ve Ödeme entegrasyonu
│   ├── maintenance/      # Arıza / Bakım talepleri, not ekleme, fotoğraf yükleme
│   ├── notifications/    # Uygulama içi anlık bildirim listesi (Zil simgesi)
│   ├── profile/          # Profil düzenleme ve güvenlik ayarları
│   └── users/            # Yöneticiler için sakin/personel listesi yönetimi
├── main.dart             # Uygulama giriş noktası (Entry Point)
└── shared/               # Ortak kullanılan arayüz bileşenleri (Widget'lar)
```

### 🧱 Bir Özelliğin (Feature) İç Yapısı
Her `feature` kendi içinde Clean Architecture katmanlarına göre bölünmüştür. Örn (`lib/features/finance/`):

```directory
finance/
├── data/                 # Veri Katmanı (Data Layer)
│   ├── datasources/      # API ile doğrudan konuşan RemoteDataSource
│   ├── dto/              # JSON'dan Dart nesnesine dönüşüm yapan DTO modelleri
│   └── repositories/     # Domain Repositories arayüzünü gerçekleştiren sınıflar
├── domain/               # İş Kuralları Katmanı (Domain Layer - Saf Dart)
│   ├── models/           # Uygulama içinde kullanılan saf veri modelleri
│   └── repositories/     # Data katmanının gerçekleştireceği soyut arayüzler
└── presentation/         # Sunum/Arayüz Katmanı (Presentation Layer)
    ├── controllers/      # Cubit/Bloc durum yöneticileri (State Management)
    ├── pages/            # Kullanıcıya gösterilen ekranlar (Pages/Views)
    └── widgets/          # O özelliğe özel küçük arayüz bileşenleri
```

### ⚡ Kullanılan Önemli Tasarım Kalıpları ve Paketler
*   **State Management (Bloc/Cubit):** Uygulama durumu tek yönlü veri akışıyla (Unidirectional Data Flow) yönetilir. Kararsız durumlar engellenir.
*   **Dependency Injection (GetIt):** Sınıflar arası bağımlılıklar (`lib/core/di/injection.dart`) dosyasında yönetilir. `sl<ClassName>()` şeklinde servis çağrısı yapılır.
*   **Ağ Katmanı (Dio):** `AuthInterceptor` sayesinde her isteğe JWT token otomatik eklenir. `LogInterceptor` ile debug modda ağ trafiği konsola basılır.
*   **Navigasyon (GoRouter):** Sayfa geçişleri, parametre aktarımları ve yetkisiz kullanıcıların yönlendirilmesi GoRouter üzerinden deklaratif olarak yönetilir.

---

## 🐍 2. Backend (Django REST Framework) Mimarisi

Backend projesi, modüler Django uygulamalarından (`apps`) oluşur. İş mantığı servislere ve sinyallere (signals) dağıtılmıştır.

### 📂 Klasör Yapısı (`apps/`)

```directory
apps/
├── accounts/             # Kullanıcı modeli, OTP, SMS ve üyelik işlemleri
├── properties/           # Apartman, Blok, Daire, Sakin (Owner/Tenant) ve Kira Sözleşmeleri
├── finance/              # Borçlar, Aidat Dönemleri, Ödemeler (Iyzico), Gelir/Giderler
├── operations/           # Bakım talepleri (Maintenance), Personel, Duyurular ve Dokümanlar
└── api/                  # REST API katmanı (View'lar, Serializer'lar, Rotalar ve İzinler)
    ├── permissions.py    # Özel DRF izin sınıfları (IsManager, IsResident, IsStaff)
    ├── serializers_*.py  # Veri dönüştürücüler (serializers_auth.py, serializers_finance.py vb.)
    ├── urls.py           # API rotaları (api/v1/ prefix'i ile başlar)
    └── views_*.py        # API uç noktaları (views_auth.py, views_finance.py vb.)
```

### 🛡️ Rol Bazlı Yetkilendirme (RBAC)
Kullanıcıların API'lere erişimi `apps/api/permissions.py` dosyasındaki özel sınıflarla denetlenir. 

```python
# Örnek: Sadece Sistem Yöneticisi veya Apartman Yöneticisi erişebilir
class IsManager(BasePermission):
    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            request.user.role in (UserRole.SYSTEM_ADMIN, UserRole.APARTMENT_MANAGER)
        )
```

### 🔔 Bildirim ve Entegrasyon Katmanı (`apps/operations/signals.py`)
Django'nun `post_save` ve `pre_save` sinyalleri (signals) kullanılarak olay odaklı (event-driven) bir bildirim yapısı kurulmuştur:
*   **WhatsApp Entegrasyonu (`WhatsAppService`):** Meta WhatsApp Cloud API kullanılarak personele atanan görev güncellemeleri veya sakinlere yapılan duyurular anlık olarak resmi WhatsApp API üzerinden iletilir (`common/services/whatsapp_service.py`).
*   **E-Posta Entegrasyonu:** Görev güncellemeleri arka plan iş parçacıkları (threading) kullanılarak asenkron şekilde kullanıcılara e-posta olarak gönderilir.
*   **Uygulama İçi Bildirimler (`Notification` modeli):** Kullanıcıların zil ikonundan gördükleri veriler veritabanına otomatik yazılır.

---

## 🛠️ 3. Yeni Geliştiriciler İçin Başlangıç Adımları

### Mobil Projeyi Çalıştırmak
1.  Flutter SDK sürümünün uyumluluğunu kontrol edin (Önerilen: Dart `^3.5.0`).
2.  `flutter pub get` komutuyla paketleri indirin.
3.  Eğer DTO veya Model üzerinde değişiklik yaptıysanız, kod üreticiyi çalıştırın:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  Bağlanılacak sunucu adresini `lib/core/config/app_environment.dart` dosyasından güncelleyin.
5.  Uygulamayı çalıştırın:
    ```bash
    flutter run
    ```

### Backend Projesini Çalıştırmak
1.  Python ortamınızı hazırlayın (Python 3.10+ önerilir) ve bağımlılıkları yükleyin:
    ```bash
    pip install -r requirements.txt
    ```
2.  Veritabanı göçlerini uygulayın:
    ```bash
    python manage.py migrate
    ```
3.  Kod bütünlüğünü test edin:
    ```bash
    python manage.py check
    ```
4.  Lokal sunucuyu başlatın:
    ```bash
    python manage.py runserver
    ```

---
*Bu el kitabı, uygulamanın teknik altyapısını ve mimari standartlarını korumak amacıyla sürekli güncellenmelidir.*
