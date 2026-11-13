# Market Regime Tracker (Flutter Mobile App) 📈📱

Orijinal Python tabanlı nicel rejim takip sisteminin doğrudan mobil cihazlarda (Android APK) çalışan, sunucusuz **Flutter / Dart** uyarlamasıdır.

## 🚀 Özellikler
- **Sunucusuz Yerel Analiz Motoru:** Yahoo Finance API'den canlı verileri çeker, EMA(50), EMA(200) ve RSI(14) hesaplayarak piyasa rejimini (Güçlü Boğa, Dengeli Boğa, Ayı, Yatay) doğrudan telefonda belirler.
- **TCMB & Harem Altın Kurları:** Merkez Bankası günlük resmi döviz kurlarını (XML) ve Harem Altın / piyasa altın fiyatlarını canlı gösterir.
- **Dinamik Sembol Yönetimi:** Ayarlar sekmesinden istediğiniz hisse, emtia veya kripto sembolünü (`THYAO.IS`, `BTC-USD`, `GC=F` vb.) ekleyip çıkarabilirsiniz.
- **Tema Desteği:** Orijinal `#0B0E11` koyu terminal teması ve açık tema arasında tek tuşla geçiş yapabilirsiniz.
- **GitHub Actions Otomatik APK Derleme:** Repo'ya push yaptığınızda GitHub Actions otomatik olarak `.apk` dosyasını derler ve `Actions > Artifacts` altından indirmenize sunar.

## 🛠️ Kurulum ve APK Derleme
```bash
flutter create --platforms=android .
flutter pub get
flutter build apk --release
```
