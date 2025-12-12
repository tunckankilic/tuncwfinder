# 🚀 CI/CD ve Fastlane Kurulum Rehberi

Bu dokümantasyon, TuncForWork Flutter uygulaması için CI/CD pipeline ve Fastlane yapılandırmasını açıklar.

> **⚠️ ÖNEMLİ:** Play Store deployment şu anda devre dışı bırakılmıştır. Sadece **iOS App Store** deployment'ı aktiftir. Android build'ler oluşturulur ancak otomatik olarak Play Store'a yüklenmez.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Fastlane Kurulumu](#fastlane-kurulumu)
- [GitHub Secrets Yapılandırması](#github-secrets-yapılandırması)
- [Android Deployment](#android-deployment)
- [iOS Deployment](#ios-deployment)
- [Sorun Giderme](#sorun-giderme)

---

## 🎯 Genel Bakış

Bu proje aşağıdaki CI/CD pipeline'ını kullanır:

```
Push/PR → Analyze & Test → Build (Android/iOS/Web) → Deploy (iOS App Store Only)
```

### Workflow Dosyaları

| Dosya                                   | Amaç                                 |
| --------------------------------------- | ------------------------------------ |
| `.github/workflows/flutter_ci.yml`      | Her push/PR'da test ve build         |
| `.github/workflows/release_android.yml` | Android build (Upload devre dışı) ⚠️ |
| `.github/workflows/release_ios.yml`     | iOS App Store deployment ✅          |

---

## 🔧 GitHub Actions Workflows

### 1. Flutter CI (`flutter_ci.yml`)

Her push ve pull request'te otomatik çalışır:

- ✅ Code analysis (flutter analyze)
- ✅ Format kontrolü
- ✅ Unit testler
- ✅ Android debug APK build
- ✅ iOS build (no codesign)
- ✅ Web build

**Tetikleme:**

```yaml
on:
  push:
    branches: [main, develop, "feature/**"]
  pull_request:
    branches: [main, develop]
```

### 2. Android Release (`release_android.yml`) ⚠️ DEVRE DIŞI

**Play Store upload şu anda devre dışıdır.** Workflow sadece App Bundle oluşturur, otomatik yükleme yapmaz.

Manuel tetikleme ile çalışır (otomatik tag tetiklemesi devre dışı):

```bash
# Manuel tetikleme
# GitHub Actions → Release Android → Run workflow → build_only seçin
```

Play Store upload'ı aktifleştirmek için:

1. `.github/workflows/release_android.yml` dosyasındaki yorumları kaldırın
2. `android/fastlane/Fastfile` dosyasındaki `upload_to_play_store` satırlarının yorumlarını kaldırın
3. Gerekli secrets'ları ekleyin

### 3. iOS Release (`release_ios.yml`)

Tag oluşturulduğunda veya manuel tetikleme ile çalışır.

---

## 📦 Fastlane Kurulumu

### Ön Koşullar

```bash
# Ruby kurulumu (rbenv önerilir)
brew install rbenv ruby-build
rbenv install 3.2.0
rbenv global 3.2.0

# Bundler kurulumu
gem install bundler
```

### iOS Fastlane Kurulumu

```bash
cd ios
bundle install
bundle exec fastlane init
```

**Mevcut Lane'ler:**

| Lane         | Açıklama                              |
| ------------ | ------------------------------------- |
| `setup`      | Flutter pub get ve CocoaPods kurulumu |
| `test`       | Testleri çalıştır                     |
| `build`      | Release build oluştur                 |
| `beta`       | TestFlight'a yükle                    |
| `production` | App Store'a yükle                     |

**Kullanım:**

```bash
cd ios
bundle exec fastlane beta
bundle exec fastlane production
```

### Android Fastlane Kurulumu

```bash
cd android
bundle install
bundle exec fastlane init
```

**Mevcut Lane'ler:**

| Lane             | Açıklama              |
| ---------------- | --------------------- |
| `setup`          | Flutter pub get       |
| `test`           | Testleri çalıştır     |
| `build_debug`    | Debug APK oluştur     |
| `build_release`  | Release APK oluştur   |
| `build_bundle`   | App Bundle oluştur    |
| `beta`           | Internal Test'e yükle |
| `alpha`          | Alpha track'e yükle   |
| `production`     | Play Store'a yükle    |
| `staged_rollout` | Kademeli release      |

**Kullanım:**

```bash
cd android

# Build oluşturma (Play Store upload YOK)
bundle exec fastlane beta          # Sadece build oluşturur
bundle exec fastlane production    # Sadece build oluşturur

# Manuel Play Store Upload (Play Console üzerinden)
# 1. build/app/outputs/bundle/release/app-release.aab dosyasını bulun
# 2. Play Console → Release → Create New Release
# 3. AAB dosyasını manuel yükleyin

# Play Store upload'ı aktif etmek için:
# android/fastlane/Fastfile içindeki yorumları kaldırın
# bundle exec fastlane beta          # Play Store Internal Test'e yükler
# bundle exec fastlane production    # Play Store'a yükler
# bundle exec fastlane staged_rollout percentage:25
```

---

## 🔐 GitHub Secrets Yapılandırması

GitHub repository → Settings → Secrets and variables → Actions

### Android Secrets ⚠️ (Play Store Devre Dışı - İleride Gerekli)

| Secret                            | Açıklama                         | Durum           |
| --------------------------------- | -------------------------------- | --------------- |
| `ANDROID_KEYSTORE_BASE64`         | Upload keystore (base64 encoded) | ✅ Gerekli      |
| `ANDROID_KEY_ALIAS`               | Keystore alias                   | ✅ Gerekli      |
| `ANDROID_KEY_PASSWORD`            | Key password                     | ✅ Gerekli      |
| `ANDROID_STORE_PASSWORD`          | Store password                   | ✅ Gerekli      |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play Service Account JSON | ⚠️ Şimdilik yok |

**Keystore'u Base64'e Dönüştürme:**

```bash
base64 -i upload-keystore.jks | pbcopy
# Clipboard'a kopyalandı, GitHub Secret'a yapıştırın
```

### iOS Secrets

| Secret                         | Açıklama                                |
| ------------------------------ | --------------------------------------- |
| `IOS_BUILD_CERTIFICATE_BASE64` | Distribution certificate (.p12, base64) |
| `IOS_P12_PASSWORD`             | P12 dosyası şifresi                     |
| `IOS_PROVISION_PROFILE_BASE64` | Provisioning profile (base64)           |
| `KEYCHAIN_PASSWORD`            | Temporary keychain password             |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID            |
| `APP_STORE_CONNECT_ISSUER_ID`  | App Store Connect Issuer ID             |
| `APP_STORE_CONNECT_API_KEY`    | App Store Connect API Key (base64)      |

**Sertifikayı Base64'e Dönüştürme:**

```bash
base64 -i Certificates.p12 | pbcopy
```

---

## 🤖 Android Deployment

> **⚠️ UYARI:** Play Store deployment şu anda devre dışıdır. Aşağıdaki adımlar gelecekte kullanmak için saklanmıştır.

### 1. Google Play Console Hazırlığı (ŞU ANDA DEVRE DIŞI)

1. [Google Play Console](https://play.google.com/console) → API access
2. Service Account oluşturun
3. JSON key dosyasını indirin
4. Play Console'da izinleri verin

### 2. Signing Key Oluşturma

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 3. key.properties Dosyası

`android/key.properties` (Git'e eklemeyin!):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 4. build.gradle Güncelleme

`android/app/build.gradle`:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}
```

---

## 🍎 iOS Deployment

### 1. Apple Developer Hazırlığı

1. [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Keys
2. API Key oluşturun (App Manager rolü)
3. Key dosyasını indirin

### 2. Match ile Code Signing (Önerilen)

Match, sertifikaları Git repo'da saklar ve tüm ekiple paylaşır.

```bash
cd ios
bundle exec fastlane match init
```

**Private repo oluşturun:**

```bash
# GitHub'da private "certificates" repo'su oluşturun
```

**Sertifikaları sync edin:**

```bash
bundle exec fastlane match appstore
bundle exec fastlane match development
```

### 3. Appfile Güncelleme

`ios/fastlane/Appfile`:

```ruby
app_identifier("site.tunckankilic.tuncforwork")
apple_id("your-apple-id@example.com")
itc_team_id("YOUR_ITC_TEAM_ID")
team_id("YOUR_TEAM_ID")
```

### 4. ExportOptions.plist

`ios/ExportOptions.plist` dosyasında `YOUR_TEAM_ID`'yi güncelleyin.

---

## 🔄 Workflow Örnekleri

### Manuel Release

```bash
# Android Build (Play Store upload DEVRE DIŞI)
cd android
bundle exec fastlane beta  # Sadece AAB oluşturur
# build/app/outputs/bundle/release/app-release.aab
# → Play Console'dan manuel yükleyin

# iOS TestFlight (AKTİF)
cd ios
bundle exec fastlane beta  # TestFlight'a otomatik yükler
```

### Git Tag ile Otomatik Release

```bash
# Version'u güncelle
# pubspec.yaml: version: 1.8.0+2

# Commit ve tag
git add .
git commit -m "Release v1.8.0"
git tag v1.8.0
git push origin main --tags
```

---

## 🐛 Sorun Giderme

### Yaygın Hatalar

**1. "No signing certificate" hatası (iOS)**

```bash
# Match ile sertifikaları yeniden sync edin
bundle exec fastlane match appstore --force
```

**2. "Upload failed" hatası (Android)**

- Service account izinlerini kontrol edin
- JSON key dosyasının doğru olduğundan emin olun

**3. "Build failed" hatası**

```bash
# Temizleyip tekrar build alın
flutter clean
flutter pub get
flutter build ios --release  # veya apk
```

**4. CocoaPods hataları**

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### Log Kontrolü

GitHub Actions → İlgili workflow → Job → Steps

### Lokal Test

```bash
# CI'da çalışacak komutları lokalde test edin
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --release --no-codesign
```

---

## 📚 Faydalı Linkler

- [Fastlane Docs](https://docs.fastlane.tools)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)

---

## 📝 Notlar

- `.gitignore`'a hassas dosyaları ekleyin:

  - `*.jks`, `*.keystore`
  - `key.properties`
  - `play-store-key.json`
  - `*.p12`
  - `*.mobileprovision`

- Production release'den önce mutlaka beta test yapın
- Version code/number'ı her release'de artırmayı unutmayın
