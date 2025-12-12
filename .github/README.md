# 🚀 GitHub Actions Workflows

Bu klasör TuncForWork projesinin CI/CD pipeline'larını içerir.

## 📋 Workflow Durumları

| Workflow            | Durum         | Açıklama                                |
| ------------------- | ------------- | --------------------------------------- |
| **Flutter CI**      | ✅ Aktif      | Her push/PR'da testler, analiz ve build |
| **iOS Release**     | ✅ Aktif      | TestFlight ve App Store deployment      |
| **Android Release** | ⚠️ Devre Dışı | Build oluşturur, Play Store'a yüklemez  |

## 🔧 Workflows

### 1. `flutter_ci.yml` - Continuous Integration ✅

**Tetikleyici:** Her push ve pull request

**İşlemler:**

- 🔍 Code analysis (`flutter analyze`)
- 📝 Format kontrolü (`dart format`)
- 🧪 Unit testler (`flutter test`)
- 🤖 Android APK build
- 🍎 iOS build (no codesign)
- 🌐 Web build
- 📊 Code coverage (Codecov)

**Çalıştırma:**
Otomatik - her push/PR'da çalışır.

---

### 2. `release_ios.yml` - iOS Deployment ✅

**Tetikleyici:**

- Git tag (`v*`)
- Manuel workflow dispatch

**İşlemler:**

- 📦 Flutter pub get
- 📱 CocoaPods kurulumu
- 🔨 iOS IPA build
- 🚀 TestFlight/App Store upload (Fastlane)

**Kullanım:**

```bash
# Git tag ile otomatik
git tag v1.7.0
git push origin --tags

# Manuel tetikleme
# GitHub → Actions → iOS Release → Run workflow → beta/production
```

**Gereksinimler:**

- iOS sertifikaları ve provisioning profiles
- App Store Connect API key
- GitHub Secrets yapılandırılmış olmalı

---

### 3. `release_android.yml` - Android Build ⚠️ (Play Store Devre Dışı)

**Tetikleyici:**

- ~~Git tag~~ (devre dışı)
- Manuel workflow dispatch only

**İşlemler:**

- 📦 Flutter pub get
- 🔨 App Bundle build
- 📤 Artifact olarak AAB yükleme
- ~~Play Store upload~~ (yorumda)

**Kullanım:**

```bash
# Sadece manuel tetikleme
# GitHub → Actions → Android Release → Run workflow → build_only
```

**Çıktı:**

- `android-release-aab` artifact (30 gün saklanır)
- Manuel Play Console'dan yükleme gerekli

**Play Store Upload Aktif Etme:**

1. `.github/workflows/release_android.yml` - yorumları kaldır
2. `android/fastlane/Fastfile` - `upload_to_play_store` yorumlarını kaldır
3. GitHub Secrets'a `PLAY_STORE_SERVICE_ACCOUNT_JSON` ekle

---

## 🔐 Gerekli Secrets

### iOS (App Store) - ✅ Yapılandırılmalı

| Secret                         | Açıklama                        |
| ------------------------------ | ------------------------------- |
| `IOS_BUILD_CERTIFICATE_BASE64` | Distribution sertifikası (.p12) |
| `IOS_P12_PASSWORD`             | P12 şifresi                     |
| `IOS_PROVISION_PROFILE_BASE64` | Provisioning profile            |
| `KEYCHAIN_PASSWORD`            | Geçici keychain şifresi         |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID                      |
| `APP_STORE_CONNECT_ISSUER_ID`  | Issuer ID                       |
| `APP_STORE_CONNECT_API_KEY`    | API Key (base64)                |

### Android (Play Store) - ⚠️ Şimdilik Opsiyonel

| Secret                            | Açıklama         | Durum              |
| --------------------------------- | ---------------- | ------------------ |
| `ANDROID_KEYSTORE_BASE64`         | Keystore dosyası | ⚠️ İleride gerekli |
| `ANDROID_KEY_ALIAS`               | Key alias        | ⚠️ İleride gerekli |
| `ANDROID_KEY_PASSWORD`            | Key şifresi      | ⚠️ İleride gerekli |
| `ANDROID_STORE_PASSWORD`          | Store şifresi    | ⚠️ İleride gerekli |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Service Account  | ⚠️ Şimdilik yok    |

---

## 📚 Detaylı Dokümantasyon

Daha fazla bilgi için ana dokümantasyona bakın:

- [CI_CD_SETUP.md](../CI_CD_SETUP.md)

## 🔄 Workflow Güncellemeleri

**Son Güncelleme:** Play Store deployment devre dışı bırakıldı
**Neden:** Şimdilik sadece iOS App Store deployment'ı yapılacak
**Etki:** Android build'ler oluşturulur ancak otomatik yüklenmez
