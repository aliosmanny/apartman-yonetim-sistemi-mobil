# Apartman Yönetim Sistemi — Mobil Uygulama Planı

> Durum: Uygulanabilir entegrasyon planı  
> Backend başlangıç sözleşmesi: `235b040` (`Endpointler hazir`)  
> API kökü: `/api/v1/` — Swagger: `/api/v1/docs/` — OpenAPI: `/api/v1/schema/`

## Yönetici özeti

Mobil uygulama Flutter ile, mevcut web sistemiyle aynı veri ve iş kurallarını kullanacak şekilde geliştirilecektir. Web uygulaması ve veritabanı yeniden yazılmayacaktır.

Backend endpoint'leri mobil geliştirmenin başlangıç sözleşmesi olarak kabul edilmiştir. Backend ve mobil geliştirme paralel ilerleyecektir:

- Ahmet mevcut Django REST API katmanındaki hata, yetki ve sözleşme düzeltmelerini sürdürecektir.
- Ali Osman Flutter uygulamasını mevcut endpoint'lere doğrudan bağlamaya başlayacaktır.
- Henüz güvenli veya tamamlanmış olmayan akışlar repository/adapter katmanında izole edilecek, ekran koduna geçici backend davranışı yayılmayacaktır.

Bu yöntemle mobil ekip backend düzeltmelerini beklemez ve hazırlanmış ekranlar API değişikliklerinde yeniden yazılmaz. İlk hedef sakin kullanıcıların temel işlemleridir; personel ve yönetici modülleri sonraki aşamalarda tamamlanacaktır.

## 1. Amaç

Bu proje, mevcut Apartman Yönetim Sistemi'nin Flutter ile geliştirilecek Android mobil uygulamasıdır.

Görev paylaşımı:

- Django backend ve REST API geliştirmesini Ahmet yapacaktır.
- Flutter mobil uygulamayı Ali Osman geliştirecektir.
- Mobil uygulama REST API üzerinden mevcut sisteme bağlanacaktır.

Mobil geliştirme API'ye bağlı olarak başlayacaktır. Geliştirme sunucusunun kullanılamadığı ekranlarda aynı repository arayüzünü kullanan mock veri kaynağı devreye alınacaktır.

## 2. Geliştirme yaklaşımı

```text
Normal geliştirme
Flutter ekranı → Repository → Remote Data Source → REST API → Django

Sunucu/endpoint kullanılamadığında
Flutter ekranı → Repository → Mock Data Source → Örnek veri
```

Ekranlar doğrudan HTTP isteği göndermeyecektir. Bu sayede API adresleri veya JSON biçimleri değişse bile ekran kodları etkilenmeyecektir.

HTML parser kullanılmayacaktır. Django Admin mobil uygulamanın veri kaynağı olmayacaktır. Zorunlu ödeme doğrulama sayfası dışında WebView temel mimarinin parçası değildir.

## 3. Uygulama kapsamı

### Kullanıcı rolleri

- Sistem yöneticisi
- Apartman/site yöneticisi
- Kat maliki
- Kiracı
- Personel

### Ana modüller

```text
Mobil Uygulama
├── Kimlik doğrulama
│   ├── Giriş
│   ├── Şifremi unuttum
│   ├── OTP doğrulama
│   └── Çıkış
├── Dashboard
├── Apartmanlar, bloklar ve daireler
├── Kat malikleri ve kiracılar
├── Kira sözleşmeleri
├── Aidat ve borçlar
├── Ödemeler
├── Gelir ve giderler
├── Bakım talepleri
├── Personeller
├── Duyurular
├── Dokümanlar
├── Bildirimler
└── Profil
```

## 4. Flutter klasör hiyerarşisi

Flutter projesi repo içindeki `mobile` klasöründe tutulacaktır.

```text
mobile/
├── android/
├── ios/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── lib/
│   ├── main.dart
│   ├── bootstrap.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router/
│   │   └── theme/
│   ├── core/
│   │   ├── config/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── errors/
│   │   ├── utils/
│   │   └── widgets/
│   ├── shared/
│   │   ├── models/
│   │   └── widgets/
│   └── features/
│       ├── auth/
│       ├── dashboard/
│       ├── properties/
│       ├── residents/
│       ├── contracts/
│       ├── finance/
│       ├── maintenance/
│       ├── announcements/
│       ├── documents/
│       ├── notifications/
│       ├── staff/
│       └── profile/
├── test/
├── integration_test/
└── pubspec.yaml
```

### Klasörlerin görevleri

| Klasör | Görevi |
|---|---|
| `app` | Uygulama başlangıcı, tema ve yönlendirme |
| `core/config` | API adresi ve ortam ayarları |
| `core/network` | HTTP istemcisi, token ve hata yönetimi |
| `core/storage` | Token ve yerel tercihlerin saklanması |
| `core/widgets` | Ortak buton, alan, yükleme ve hata bileşenleri |
| `features` | İş modülleri ve ekranlar |
| `shared` | Birden fazla modülün kullandığı modeller ve widget'lar |

## 5. Feature yapısı

Her modül veri kaynağından bağımsız hazırlanacaktır.

```text
features/finance/
├── data/
│   ├── datasources/
│   │   ├── finance_mock_data_source.dart
│   │   └── finance_remote_data_source.dart
│   ├── dto/
│   │   ├── debt_dto.dart
│   │   └── payment_dto.dart
│   ├── mappers/
│   │   └── finance_mapper.dart
│   └── repositories/
│       └── finance_repository_impl.dart
├── domain/
│   ├── models/
│   │   ├── debt.dart
│   │   └── payment.dart
│   └── repositories/
│       └── finance_repository.dart
└── presentation/
    ├── controllers/
    ├── pages/
    └── widgets/
```

### Veri akışı

```text
Page
  ↓
Controller
  ↓
Repository arayüzü
  ↓
Mock veya Remote Data Source
  ↓
Örnek veri veya REST API
```

## 6. API bağlantısından bağımsız yapılacak işler

- Flutter proje altyapısı
- Tema, renkler ve ortak bileşenler
- Sayfa yönlendirmeleri
- Rol bazlı menü yapısı
- Tüm domain modelleri
- Mock repository ve örnek veriler
- Giriş ekranının arayüzü
- Yönetici, sakin ve personel dashboard'ları
- Borç, ödeme ve finans ekranları
- Bakım talebi ekranları
- Duyuru, doküman ve bildirim ekranları
- Profil ekranı
- Form doğrulamaları
- Loading, empty ve error durumları
- Widget ve controller testleri

Bu çalışmalar gerçek API entegrasyonuyla paralel yürütülecektir. Mock kaynaklar yalnızca sunucunun veya ilgili endpoint'in kullanılamadığı geliştirme senaryolarında etkinleştirilecektir.

## 7. Mevcut API'ye bağlanırken yapılacak işler

1. Development ve production `baseUrl` değerleri tanımlanır.
2. Login ve token yenileme bağlanır.
3. DTO sınıfları OpenAPI şeması ve gerçek JSON cevaplarına göre oluşturulur.
4. Remote data source metotları endpoint'lere bağlanır.
5. Mock repository yerine remote repository etkinleştirilir.
6. Dosya yükleme ve indirme bağlanır.
7. Ödeme başlatma ve sonuç sorgulama bağlanır.
8. Gerçek rollerle uçtan uca test yapılır.
9. Hata cevapları kullanıcı mesajlarına dönüştürülür.

## 8. Kimlik doğrulama planı

Mobil uygulama backend'in sağlayacağı token tabanlı giriş sistemini kullanacaktır.

Beklenen akış:

```text
Telefon + şifre
→ Login API
→ Access token + refresh token + kullanıcı bilgisi
→ Token'ları güvenli saklama
→ İsteklere access token ekleme
→ Süre dolunca refresh token ile yenileme
→ Yenileme başarısızsa giriş ekranına dönme
```

Flutter tarafında giriş sistemi API'den bağımsız bir `AuthRepository` arayüzü üzerinden hazırlanacaktır.

## 9. Rol bazlı navigasyon

### Sistem ve apartman yöneticisi

```text
Ana Sayfa
Yapı Yönetimi
Finans
Talepler
Menü
```

### Kat maliki ve kiracı

```text
Ana Sayfa
Borçlar
Talepler
Duyurular
Profil
```

### Personel

```text
Ana Sayfa
Atanan İşler
Tamamlananlar
Bildirimler
Profil
```

## 10. Ortam ayarları

API adresi kaynak kod içine dağınık biçimde yazılmayacaktır.

```text
Development: Ahmet'ten çalışan test sunucusu adresi alınacak
Production:  API sunucuya alındığında Ahmet'ten alınacak
```

Flutter tarafında örnek yapı:

```text
AppEnvironment
├── development
├── staging
└── production
```

Mobil uygulamaya veritabanı şifresi, Django secret key, Iyzico secret key veya diğer sunucu sırları eklenmeyecektir.

## 11. Kesin backend endpoint envanteri

Bu plan için `apps/api/urls.py` dosyasındaki adresler esastır. Tüm istekler `/api/v1/` kökü altındadır.

### Kimlik doğrulama ve profil

```text
POST auth/login/                    Telefon + şifre ile access/refresh alma
POST auth/refresh/                  Access token yenileme
POST auth/logout/                   Refresh token blacklist
POST auth/register/                 Apartman yöneticisi kaydı
POST auth/otp/send/                 OTP gönderme
POST auth/otp/verify/               OTP doğrulama
POST auth/forgot-password/          Sıfırlama OTP isteği
POST auth/forgot-password/verify/   Sıfırlama kodu kontrolü
POST auth/forgot-password/reset/    Yeni şifre belirleme
GET  profile/me/                    Profil
PUT  profile/me/                    Profil güncelleme
POST profile/change-password/       Şifre değiştirme
```

### Dashboard ve yardımcı veriler

```text
GET  dashboard/
GET  dashboard/chart-data/
GET  enums/all/
GET  enums/{name}/
POST devices/register/
POST devices/unregister/
```

`devices/*` endpoint'leri backend tarafında FCM cihaz modeli tamamlanana kadar hazır cevap veren yer tutucu olarak ele alınacaktır.

### Apartman, blok, daire ve sakinler

```text
GET,POST             apartments/
GET,PUT,PATCH,DELETE apartments/{id}/
GET                  apartments/{id}/stats/
GET,POST             apartments/{apartmentId}/blocks/
GET,PUT,PATCH,DELETE blocks/{id}/
GET                  blocks/{blockId}/units/
GET,PUT,PATCH        units/{id}/
GET                  my-units/
GET,POST             owners/
GET,PUT,PATCH,DELETE owners/{id}/
GET,POST             tenants/
GET,PUT,PATCH,DELETE tenants/{id}/
GET,POST             contracts/
GET,PUT,PATCH        contracts/{id}/
GET                  contracts/{id}/download/
```

### Finans ve ödeme

```text
GET,POST             due-periods/
GET,PUT,PATCH,DELETE due-periods/{id}/
GET,POST             debts/
GET                  debts/summary/
GET,PUT,PATCH,DELETE debts/{id}/
GET                  debts/{debtId}/payments/
POST                 debts/{debtId}/pay/
POST                 debts/{debtId}/pay/manual/
POST                 payments/callback/            Sunucu/İyzico callback'i; mobil çağırmaz
PUT                  payments/{id}/confirm/
GET,POST             incomes/
GET,PUT,PATCH,DELETE incomes/{id}/
GET,POST             expenses/
GET,PUT,PATCH,DELETE expenses/{id}/
GET                  reports/dues/
GET                  reports/finance/
GET                  reports/maintenance/
```

### Operasyon

```text
GET,POST             staff/
GET,PUT,PATCH,DELETE staff/{id}/
GET,POST             maintenance-requests/
GET,PUT,PATCH        maintenance-requests/{id}/
PATCH                maintenance-requests/{id}/status/
GET                  maintenance-requests/{id}/logs/
GET,POST             announcements/
GET,PUT,PATCH,DELETE announcements/{id}/
GET                  notifications/
GET                  notifications/unread-count/
POST                 notifications/mark-all-read/
PATCH                notifications/{id}/read/
GET,POST             documents/
GET,PUT,PATCH,DELETE documents/{id}/
GET                  documents/{id}/download/
```

Liste endpoint'leri Django REST Framework sayfalamasını kullanır: `count`, `next`, `previous`, `results`. Filtreler URL query parametreleriyle gönderilir. Dosya yükleyen endpoint'lerde `multipart/form-data`, indirmelerde binary response kullanılır.

## 12. Mobil uyumluluk ve bilinen backend davranışları

Mobil geliştirme durdurulmayacaktır. Aşağıdaki davranışlar tek bir uyumluluk katmanında tutulacaktır:

| Konu | Mobilin geçici davranışı | Kalıcı hedef |
|---|---|---|
| Kayıt OTP kanıtı | Kayıt isteğinde backend'in beklediği `verified_phone` alanı gönderilir | Backend imzalı/tek kullanımlı OTP doğrulama kanıtı üretir |
| Şifre sıfırlama | Kod, ayrı verify isteğiyle tüketilmeden doğrudan reset isteğine eklenir | Verify sonrası reset token kullanılır |
| Ödeme yetkisi | Mobil sadece kullanıcının API listelerinde aldığı borç ID'leriyle işlem yapar | Backend her detay/ödeme sorgusunu apartman ve daire kapsamına alır |
| Push cihaz kaydı | Arayüz ve servis soyutlaması hazırlanır; başarı cevabı gerçek kayıt sayılmaz | FCM cihaz modeli ve gerçek kayıt tamamlanır |
| CORS | Android native HTTP isteklerini etkilemez | Production origin ayarları backend'de daraltılır |

Uyumluluk kodları `core/network/compatibility` veya ilgili feature mapper/data source katmanında tutulacak ve `TODO(api-contract)` etiketiyle izlenecektir.

## 13. Geliştirme aşamaları

### Aşama 1 — Proje altyapısı

- Flutter projesini oluşturma
- Tema ve ortak bileşenler
- Router ve rol bazlı yönlendirme
- Network ve storage arayüzleri
- Mock/remote veri kaynağı ayrımı

### Aşama 2 — Kimlik doğrulama ve uygulama kabuğu

- Splash
- Giriş
- Şifremi unuttum ve OTP arayüzleri
- Rol bazlı alt menü
- Oturum durumu yönetimi

### Aşama 3 — Sakin uygulaması

- Dashboard
- Borç ve ödeme ekranları
- Bakım talebi
- Duyurular
- Bildirimler
- Dokümanlar
- Profil

### Aşama 4 — Personel uygulaması

- Atanan talepler
- Durum güncelleme
- Personel notu
- Sonuç fotoğrafı
- Tamamlanan işler

### Aşama 5 — Yönetici uygulaması

- Yönetici dashboard
- Apartman, blok ve daireler
- Malik, kiracı ve personel
- Aidat ve toplu borçlandırma
- Ödeme, gelir ve giderler
- Bakım atama
- Duyuru ve doküman yönetimi

### Aşama 6 — Kalan API entegrasyonu

- Gerçek endpoint'leri bağlama
- Token ve yetkilendirme
- Dosya ve ödeme işlemleri
- Gerçek veri ve rol testleri

### Aşama 7 — Yayın hazırlığı

- Entegrasyon testleri
- Hata ve performans düzeltmeleri
- Uygulama ikonu ve açılış ekranı
- Release APK/AAB

## 14. İlk teslim edilebilir sürüm

Geliştirme sunucusu olmadan gösterilebilir sürüm:

```text
Mock giriş
→ Rol seçimi
→ Rol bazlı dashboard
→ Modüller arasında gezinme
→ Liste ve detay ekranları
→ Form akışları
```

Mevcut API'ye bağlı çalışan sürüm:

```text
Gerçek giriş
→ Token saklama
→ Gerçek kullanıcı ve rol
→ REST API'den veriler
→ Kayıt oluşturma/güncelleme
→ Dosya ve ödeme işlemleri
→ Çıkış
```

## 15. Kabul ve sürümleme

`235b040` commit'indeki API, mobil uygulamanın **v1 başlangıç sözleşmesi olarak kabul edilmiştir**. Mobil uygulama mevcut API'ye bağlanarak geliştirilecek; gerektiğinde repository arayüzleri ve mock veri kaynakları kullanılacaktır.

Backend değişiklikleri ekranlara doğrudan yansıtılmayacak; DTO, mapper ve remote data source katmanlarında karşılanacaktır. Kırıcı API değişikliklerinde backend commit'i ve OpenAPI şeması birlikte kaydedilecektir.

## 16. Koordinasyon ve teslim şartları

Mobil uygulamanın gerçek verilerle tamamlanabilmesi için Ahmet tarafından aşağıdakilerin paylaşılması gerekir:

- Çalışan development/test API adresi
- Her API değişikliğinde güncel OpenAPI şeması
- Her kullanıcı rolü için test hesabı
- Dosya yükleme ve ödeme akışının teknik bilgileri
- API değişikliklerinin test veya canlı sunucuya aktarılması

Ali Osman tarafından teslim edilecekler:

- Flutter kaynak kodu
- Android üzerinde çalışan uygulama
- Rol bazlı ekranlar ve navigasyon
- REST API entegrasyonları
- Temel unit, widget ve entegrasyon testleri
- Release APK/AAB çıktısı

Endpoint ayrıntıları `API_SOZLESMESI_TASLAGI.md` belgesinde izlenir. Çalışan backend kodu ile belge farklıysa `apps/api/urls.py` ve üretilen OpenAPI şeması kaynak kabul edilir; fark belgeye ve mobil adapter katmanına işlenir.
