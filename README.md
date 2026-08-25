# 🏢 Apartman & Site Yönetim Sistemi - Mobil Uygulama

Bu proje, apartman, site ve toplu konut yönetim süreçlerini tamamen dijitalleştirmek amacıyla geliştirilmiş, modern ve rol bazlı bir mobil uygulamadır. Sakinler, yöneticiler ve saha personeli arasındaki iletişimi ve operasyonları tek bir çatı altında birleştirir.

---

## ✨ Öne Çıkan Özellikler

Uygulama, sisteme giriş yapan kullanıcının rolüne göre dinamik olarak şekillenen **3 farklı arayüze (Shell)** sahiptir:

### 1. 👑 Yönetici Modülü (Manager Dashboard)
*   **Finansal Yönetim:** Aidat dönemleri oluşturma, dairelere borç tanımlama, gelir/gider takibi ve finansal özet grafikler.
*   **Kullanıcı Yönetimi:** Apartmandaki sakinlerin (Kat Maliki ve Kiracı) ve saha personelinin listelenmesi, yeni kullanıcı ekleme ve profil yönetimi.
*   **Talep ve Arıza Yönetimi:** Sakinlerden gelen bakım/arıza taleplerini listeleme, aciliyet durumuna göre sınıflandırma ve saha personeline görev atama.
*   **Duyurular & Belgeler:** Tüm apartmana anlık duyurular yayınlama ve karar defteri, yönetmelik gibi belgeleri sisteme yükleme.

### 2. 🏡 Sakin Modülü (Resident - Kat Maliki & Kiracı)
*   **Kolay Ödeme (Iyzico Entegrasyonu):** Birikmiş aidat ve borçları uygulama içinden 3D Secure güvencesiyle kredi kartıyla ödeme.
*   **Arıza Bildirimi (Bakım Talebi):** Ortak alan veya daire içi arızaları fotoğraf çekip detay ekleyerek doğrudan yönetime iletme.
*   **Sözleşme & Belge Takibi:** Aktif kira sözleşmelerini görüntüleme ve PDF olarak telefona indirme.
*   **Duyuru & Bildirim Alıcı:** Yönetimden gelen duyurulardan ve ödeme hatırlatmalarından anlık haberdar olma.

### 3. 🛠️ Saha Personeli Modülü (Staff Dashboard)
*   **Görev Takip Listesi:** Kendisine atanan işleri "Bekleyen", "İşlemde" ve "Tamamlanan" şeklinde listeleme.
*   **İş Güncelleme (Talep Düzenleme):** İşin detayını inceleme, süreci "İşlem Devam Ediyor" veya "Tamamlandı" olarak güncelleme, personel notu yazma ve biten işin fotoğrafını çekip sisteme yükleme.

---

## 🛠️ Kullanılan Teknolojiler & Mimari

Uygulama, sürdürülebilir, ölçeklenebilir ve test edilebilir bir kod tabanı oluşturmak için **Clean Architecture (Temiz Mimari)** standartlarına sadık kalınarak geliştirilmiştir.

*   **Çatı (Framework):** Flutter (Dart) - Tek kod tabanı ile Android & iOS.
*   **Mimari Yapı (Architecture):** Temiz Mimari (Clean Architecture) ve Özellik Odaklı (Feature-First) dikey bölümleme.
*   **Durum Yönetimi (State Management):** Flutter BLoC & Cubit (Tahmin edilebilir, kararlı ve performanslı veri akışı).
*   **Navigasyon:** GoRouter (Deklaratif yönlendirme, derin bağlantı / deep linking desteği).
*   **Bağımlılık Enjeksiyonu (DI):** GetIt (Sınıflar arası sıkı bağımlılıkları önleyen Servis Bulucu şablonu).
*   **Ağ Yönetimi:** Dio HTTP Client (JWT Token otomatik yenileme, hata yakalama, dosya transferi ve ağ loglama).
*   **Güvenli Depolama:** Flutter Secure Storage (Kullanıcı giriş bilgileri ve JWT anahtarlarını şifreli saklama).

---

## ⚙️ Kurulum ve Başlangıç

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları takip edin:

### 1. Gereksinimler
*   Flutter SDK (Önerilen: `^3.5.0` veya üzeri)
*   Dart SDK (Önerilen: `^3.5.0` veya üzeri)
*   Android Studio / VS Code (Flutter eklentileri kurulu)

### 2. Bağımlılıkları İndirme
Proje kök dizininde aşağıdaki komutu çalıştırarak gerekli paketleri indirin:
```bash
flutter pub get
```

### 3. Kod Üretimini Tetikleme
DTO (Veri Transfer Nesneleri) ve JSON dönüştürücü kodların otomatik üretilmesi için `build_runner` aracını çalıştırın:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. API Bağlantı Ayarları
Uygulamanın bağlanacağı backend sunucu adresini değiştirmek veya yerel test sunucusunu (`localhost`) tanımlamak için aşağıdaki dosyayı düzenleyin:
`lib/core/config/app_environment.dart`

```dart
static String get baseUrl {
  switch (_current) {
    case AppEnv.development:
      return 'https://siteyonetimi.argeyazilim.tr/api/v1'; // Canlı veya test sunucusu API adresi
    ...
  }
}
```

### 5. Uygulamayı Çalıştırma
Cihazınızı (Emulator veya Fiziksel Telefon) bağladıktan sonra uygulamayı başlatın:
```bash
flutter run
```

---

## 📁 Temel Klasör Yapısı

```directory
lib/
├── app/                  # Genel tema ve rota (navigasyon) tanımları
├── core/                 # DI, Güvenli Depolama, Ağ ve Ortam Ayarları gibi ortak modüller
├── shared/               # Uygulama genelinde ortak kullanılan Widget'lar
└── features/             # Özellik bazlı dikey katmanlar
    ├── auth/             # Giriş/Çıkış, Şifre Değiştirme ve OTP işlemleri
    ├── dashboard/        # Rol bazlı ana paneller (Yönetici, Sakin, Personel)
    ├── finance/          # Aidat, Borç ödemeleri ve Gelir/Gider yönetimi
    ├── maintenance/      # Arıza / Bakım talepleri takip süreçleri
    ├── notifications/    # Uygulama içi bildirim zili modülü
    └── users/            # Sakin ve Personel yönetim ekranları
```
