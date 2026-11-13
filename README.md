# Market Regime Tracker (Flutter Mobile App) 📈📱

Orijinal Python tabanlı nicel rejim takip sisteminin doğrudan mobil cihazlarda (Android APK) çalışan, sunucusuz **Flutter / Dart** uyarlamasıdır.

## 🚀 Özellikler
- **Sunucusuz Yerel Analiz Motoru:** Yahoo Finance API'den canlı verileri çeker, EMA(50), EMA(200) ve RSI(14) hesaplayarak piyasa rejimini (Güçlü Boğa, Dengeli Boğa, Ayı, Yatay) doğrudan telefonda belirler.
- **TCMB & Harem Altın Kurları:** Merkez Bankası günlük resmi döviz kurlarını (XML) ve Harem Altın / piyasa altın fiyatlarını canlı gösterir.
- **Dinamik Sembol Yönetimi:** Ayarlar sekmesinden istediğiniz hisse, emtia veya kripto sembolünü (`THYAO.IS`, `BTC-USD`, `GC=F` vb.) ekleyip çıkarabilirsiniz.
- **Tema Desteği:** Orijinal `#0B0E11` koyu terminal teması ve açık tema arasında tek tuşla geçiş yapabilirsiniz.
- **GitHub Actions Otomatik APK Derleme:** Repo'ya push yaptığınızda GitHub Actions otomatik olarak `.apk` dosyasını derler ve `Actions > Artifacts` altından indirmenize sunar.

---

## 🛠️ Teknoloji Yığını ve Kütüphaneler

- **Language:** Python 3.x (Orijinal Algoritma) / Dart 3.x (Flutter Mobil)
- **Data Retrieval:** `yfinance` / Yahoo Finance Chart API, TCMB XML, Harem Altın API
- **Data Processing & Math:** `pandas`, `numpy` / Yerel Dart EMA & RSI Motoru
- **Data Visualization:** `matplotlib` (with custom path effects and subplots) / `fl_chart`
- **API Dispatch:** `requests` / `http`

---

## 📂 Proje Yapısı (Project Structure)

```text
├── lib/
│   ├── main.dart                  # Flutter ana arayüzü, tema yönetimi ve ekran sekmeleri
│   └── services/
│       └── market_service.dart    # Nicel rejim analizi, EMA/RSI hesaplayıcı ve TCMB/Harem veri servisleri
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml    # İnternet izinleri ve uygulama ayarları
├── .github/
│   └── workflows/
│       └── build_apk.yml          # GitHub Actions otomatik APK derleme iş akışı
├── pubspec.yaml                   # Flutter paket bağımlılıkları (http, xml, fl_chart vb.)
└── README.md                      # Proje dokümantasyonu
```

---

## ⚠️ Sorumluluk Reddi (Disclaimer)
Bu depo yalnızca eğitim, bilgilendirme ve araştırma amaçlıdır. Bu botlar ve uygulama tarafından üretilen komut dosyaları ve analizler hiçbir şekilde finansal, yatırım veya alım-satım tavsiyesi **teşkil etmez**. Her zaman kendi araştırmanızı yapın ve herhangi bir finansal karar almadan önce lisanslı bir uzmana danışın.

---

## ⚙️ Kurulum ve APK Derleme
```bash
flutter create --platforms=android --project-name market_regime_tracker .
flutter pub get
flutter build apk --release
```