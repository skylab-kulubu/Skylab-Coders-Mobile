# SkyLab Coders

SkyLab Kulübü organizasyonundaki tüm projeleri ve katkı sağlayıcıları analiz eden, "Ayın En İyi Kodlayanı" gibi ünvanları belirleyen mobil/web uygulaması. Artık Backend destekli!

## Mimari

*   **Frontend**: Flutter (Mobil/Web/Desktop)
*   **Backend**: Node.js, Express, Prisma
*   **Database**: PostgreSQL
*   **Altyapı**: Docker

## Kurulum ve Çalıştırma

### 1. Backend (Sunucu ve Veritabanı)

Önce backend servislerini ayağa kaldırın. Bu işlem PostgreSQL veritabanını ve Node.js API servisini başlatır.

```bash
cd backend
# docker-compose.yml dosyasında GITHUB_TOKEN environment değişkenine token'ınızı yazabilirsiniz.
docker-compose up -d
```

Servisler şu adreslerde çalışacaktır:
*   API: `http://localhost:3001`
*   DB: `localhost:5433`

### 2. Frontend (Mobil Uygulama)

Uygulamayı çalıştırın.

```bash
# Ana dizinde (Skylab-Coders)
flutter run
```

## Özellikler

*   **GitHub Entegrasyonu**: Organizasyon altındaki tüm public repoları tarar.
*   **Zamanlanmış Görevler**: Her gün 00:00 ve 12:00'da veriler otomatik güncellenir.
*   **Detaylı Analiz**: Günlük, Haftalık, Aylık ve Yıllık liderlik tabloları.
*   **Ayın En İyisi**: İstatistiklere göre otomatik belirlenir.
*   **Modern Arayüz**: Glassmorphism ve Tailwind renk paleti ile premium tasarım.

## Token Ayarı

Backend'in GitHub API'den veri çekebilmesi için bir GitHub Personal Access Token gereklidir. Bunu `backend/docker-compose.yml` dosyası içindeki `GITHUB_TOKEN` alanına eklemeniz önerilir. Aksi takdirde API limitlerine takılabilirsiniz.
