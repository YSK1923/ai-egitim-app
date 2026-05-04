# 🤖 AI Öğretmenim - Adaptif Öğrenme Uygulaması

PDF dökümanınızdaki **"Akıllı Soru Önceliklendirme ve Eğlenceli Adaptif Öğrenme Sistemi"** vizyonuna dayalı Flutter uygulaması.

## 📱 Uygulama Özellikleri

### 9 Modülün Tamamı Uygulandı:
| # | Modül | Açıklama |
|---|-------|----------|
| 1 | **Müfredat Motoru** | AI ile konu bazlı dinamik soru üretimi |
| 2 | **Soru Analiz Motoru** | Yanlış cevapları analiz eder, kök neden bulur |
| 3 | **Öğrenci Modelleme** | XP, seviye, seri, konu hakimiyeti takibi |
| 4 | **Soru Önceliklendirme** | En zayıf konuya otomatik yönlendirme |
| 5 | **Çıkma İhtimali Motoru** | LGS/YKS sınav olasılıklarını gösterir |
| 6 | **Bilgi Kazancı Motoru** | Kişiselleştirilmiş günlük içgörüler |
| 7 | **Adaptif Öğretim** | Her yanlış cevapta farklı açıklama stili |
| 8 | **Eğlenceli Öğretim** | Emoji, hikaye, oyunlaştırma, RPG modu |
| 9 | **Teknik Mimari** | Provider state management, SharedPreferences |

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Android Studio veya VS Code
- Anthropic API anahtarı

### Adımlar

```bash
# 1. Projeyi klonlayın / açın
cd ai_egitim_app

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. API anahtarını ekleyin
# lib/services/ai_service.dart dosyasını açın
# 'YOUR_ANTHROPIC_API_KEY' yazan yeri kendi anahtarınızla değiştirin

# 4. Android APK üretin
flutter build apk --release

# 5. iOS için (Mac gerekli)
flutter build ios --release
```

### API Anahtarı Nereden Alınır?
1. https://console.anthropic.com adresine gidin
2. Kayıt olun / giriş yapın
3. "API Keys" bölümünden yeni anahtar oluşturun
4. `lib/services/ai_service.dart` dosyasında `_apiKey` değişkenine yapıştırın

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/
│   ├── student_model.dart       # Öğrenci veri modeli
│   └── question_model.dart      # Soru ve konu modelleri
├── services/
│   ├── ai_service.dart          # Anthropic AI entegrasyonu (7 modül)
│   └── student_model_service.dart # Öğrenci veri yönetimi
└── screens/
    ├── home_screen.dart         # Ana sayfa dashboard
    ├── study_screen.dart        # Çalışma ekranı (adaptif öğretim)
    ├── topic_selection_screen.dart # Konu seçimi
    └── profile_screen.dart      # Profil ve başarılar
```

## 🎮 Öğrenme Deneyimi

- **Oyunlaştırılmış**: XP, seviyeler, rozetler, seriler
- **Hikaye Tabanlı**: Her soru bir macera bağlamında
- **Emoji Destekli**: Tüm arayüzde emoji kullanımı
- **Adaptif**: Öğrenci seviyesine göre zorluk ayarı
- **Asla Tıkanmaz**: Her yanlış cevapta 3 farklı açıklama yöntemi

## 📦 APK'yı Hızlı Almak İçin

**Codemagic (ücretsiz):**
1. https://codemagic.io adresine gidin
2. GitHub'a projeyi yükleyin
3. Codemagic'e bağlayın
4. APK otomatik üretilir

## 💡 Önemli Notlar

- API anahtarı için aylık ~$10-20 maliyet öngörülmektedir
- Soru başına yaklaşık 1000 token kullanılmaktadır
- Offline mod için soru önbelleği eklenebilir
