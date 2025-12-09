# TuncForWork (Job Tinder)

Flutter tabanlı eşleşme / kariyer destek uygulaması. Firebase Auth, Firestore, Cloud Messaging, GetX, ScreenUtil, Google Fonts kullanır.

## Gereksinimler

- Flutter 3.19+ (Dart 3.1+)
- Firebase projesi (Android, iOS, Web için `firebase_options.dart` mevcut olmalı)
- Xcode/Android Studio CLI toolchain

## Kurulum

```bash
flutter pub get
```

### Firebase

- `android/app/google-services.json` ve `ios/Runner/GoogleService-Info.plist` dosyalarını kendi proje değerlerinizle güncelleyin.
- Bildirimler için APNs sertifikası/iOS izinleri ve Android kanal ayarlarını kendi projenize göre yapılandırın.

### Bildirim Backend’i (Firebase Cloud Functions)

İstemci FCM sunucu anahtarını tutmaz; `sendNotification` adlı callable Cloud Function’a payload gönderir, Admin SDK FCM’ye iletir.

Örnek Function (TypeScript):

```ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

export const sendNotification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login required");
    }
    const { target, notification, data: extra } = data;
    if (!target?.token && !target?.tokens) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "token(s) required"
      );
    }
    const message: admin.messaging.Message = {
      token: target.token,
      tokens: target.tokens,
      notification: {
        title: notification?.title,
        body: notification?.body,
      },
      data: {
        ...extra,
        notification_type: notification?.category ?? "general",
        channel: notification?.channel ?? "general",
      },
    };
    await admin.messaging().send(message as any);
    return { ok: true };
  }
);
```

İstemci tarafında ek bir ayara gerek yok; `push_notification_system.dart` callable’ı otomatik kullanır.

## Çalıştırma

```bash
flutter run
```

## Test

### Hızlı Test

```bash
# Tüm testleri çalıştır
flutter test

# Coverage ile çalıştır
flutter test --coverage

# Belirli bir test dosyası
flutter test test/unit/service/error_handler_test.dart
```

### Test Coverage Raporu

```bash
# Script ile (önerilen)
./scripts/run_tests.sh

# Manuel
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Yapısı

```
test/
├── unit/              # Unit testler (%80+ coverage hedefi)
├── widget/            # Widget testleri
├── integration/       # Integration testleri
└── mocks/            # Mock sınıflar
```

**Detaylı kılavuz:** [Test Coverage Guide](test/TEST_COVERAGE_GUIDE.md)

**Mock servisler:** `test/mocks/mock_additional_services.dart` kariyer önerisi ve bildirim akışını bağımsız test etmek için kullanılabilir.

## Fastlane (yapılacak)

- iOS/Android CI-CD ve store dağıtımı için Fastlane entegrasyonu eklenecek. Kurulum: Ruby + bundler, `Gemfile` oluşturulup lane’ler tanımlanacak.
