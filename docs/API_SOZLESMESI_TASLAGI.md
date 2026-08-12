# Mobil Uygulama API Sözleşmesi

Bu belge, Flutter mobil uygulama ile Django REST API arasındaki bağlantıyı izlemek için hazırlanmıştır. Başlangıç sözleşmesi backend `235b040` commit'idir.

> API kökü `/api/v1/`, Swagger `/api/v1/docs/`, makinece okunabilir şema `/api/v1/schema/` adresindedir. Endpoint envanteri için mobil planın 11. bölümü ve `apps/api/urls.py` esastır.

## Ahmet'ten gerekli temel bilgiler

- Development API adresi
- Production API adresi
- Login, refresh token ve logout endpoint'leri
- Her endpoint için örnek request ve response
- Sayfalama ve filtreleme biçimi
- Dosya yükleme yöntemi
- Ödeme başlatma ve sonuç sorgulama akışı
- Her rol için test hesabı

## Ortak cevap beklentisi

Başarılı cevap örneği:

```json
{
  "data": {},
  "message": "İşlem başarılı"
}
```

Hata cevabı örneği:

```json
{
  "message": "Girilen bilgiler geçersiz.",
  "errors": {
    "field_name": ["Hata açıklaması"]
  }
}
```

Liste cevaplarında sayfalama bilgisi bulunmalıdır:

```json
{
  "count": 100,
  "next": "...",
  "previous": null,
  "results": []
}
```

## Kimlik doğrulama

```text
POST /api/v1/auth/login/
POST /api/v1/auth/refresh/
POST /api/v1/auth/logout/
POST /api/v1/auth/forgot-password/
POST /api/v1/auth/otp/send/
POST /api/v1/auth/otp/verify/
POST /api/v1/auth/forgot-password/verify/
POST /api/v1/auth/forgot-password/reset/
POST /api/v1/auth/register/
GET  /api/v1/profile/me/
PUT  /api/v1/profile/me/
POST /api/v1/profile/change-password/
```

Login cevabında beklenen bilgiler:

```json
{
  "access": "...",
  "refresh": "...",
  "user": {
    "id": 1,
    "phone": "5XXXXXXXXX",
    "first_name": "Ad",
    "last_name": "Soyad",
    "role": "tenant"
  }
}
```

## Dashboard

```text
GET /api/v1/dashboard/
```

Endpoint giriş yapan kullanıcının rolüne uygun dashboard verisini dönmelidir.

## Yapı ve sakin yönetimi

```text
/api/v1/apartments/
/api/v1/apartments/<id>/blocks/
/api/v1/blocks/<id>/
/api/v1/blocks/<id>/units/
/api/v1/units/<id>/
/api/v1/my-units/
/api/v1/owners/
/api/v1/tenants/
/api/v1/contracts/
```

## Finans

```text
/api/v1/due-periods/
/api/v1/debts/
/api/v1/incomes/
/api/v1/expenses/
GET  /api/v1/debts/summary/
GET  /api/v1/debts/<id>/payments/
POST /api/v1/debts/<id>/pay/
POST /api/v1/debts/<id>/pay/manual/
PUT  /api/v1/payments/<id>/confirm/
```

## Operasyon

```text
/api/v1/staff/
/api/v1/maintenance-requests/
/api/v1/announcements/
/api/v1/documents/
/api/v1/notifications/
GET  /api/v1/notifications/unread-count/
POST /api/v1/notifications/mark-all-read/
PATCH /api/v1/notifications/<id>/read/
```

## Dosya işlemleri

Bakım fotoğrafı ve doküman yükleme endpoint'leri `multipart/form-data` kabul etmelidir. İzin verilen dosya türleri ve maksimum boyut backend tarafından bildirilmelidir.

## Yetkilendirme

Backend mevcut Django kurallarını API tarafında da uygulamalıdır:

- Sistem yöneticisi tüm verilere erişebilir.
- Apartman yöneticisi yalnızca yönettiği apartmanlara erişebilir.
- Malik ve kiracı yalnızca bağlı oldukları dairelerin verilerine erişebilir.
- Personel yalnızca kendisine atanan talepleri görüntüleyebilir ve güncelleyebilir.

Flutter yalnızca kullanıcı deneyimi için ekranları role göre gizler. Asıl erişim kontrolü backend tarafından yapılmalıdır.

## Entegrasyon süreci

Her endpoint hazır olduğunda Ahmet aşağıdaki bilgileri mobil tarafa iletmelidir:

```text
Endpoint adresi
HTTP metodu
Gönderilecek alanlar
Başarılı cevap örneği
Hata cevabı örneği
İzin verilen roller
```

Flutter tarafındaki ilgili mock data source daha sonra remote data source ile değiştirilecektir.
