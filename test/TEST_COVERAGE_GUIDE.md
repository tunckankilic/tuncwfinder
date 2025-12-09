# 📊 Test Coverage Kılavuzu

Bu dosya TuncForWork projesinde test coverage'ı nasıl ölçeceğinizi ve artıracağınızı açıklar.

---

## 🎯 Hedefler

- **Unit Test Coverage:** %80+
- **Widget Test Coverage:** %60+
- **Integration Test Coverage:** %40+
- **Toplam Coverage:** %70+

---

## 🚀 Hızlı Başlangıç

### 1. Tüm Testleri Çalıştır ve Coverage Oluştur

```bash
# Tüm testleri coverage ile çalıştır
flutter test --coverage

# Belirli bir klasör için
flutter test test/unit --coverage

# Belirli bir dosya için
flutter test test/unit/service/error_handler_test.dart --coverage
```

### 2. Coverage Raporunu Görüntüle

```bash
# HTML rapor oluştur (önce lcov kurmalısınız)
brew install lcov  # macOS
sudo apt-get install lcov  # Linux

# HTML rapor oluştur
genhtml coverage/lcov.info -o coverage/html

# Raporu aç
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### 3. VS Code ile Coverage Görüntüleme

1. [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) extension'ını yükle
2. `Cmd+Shift+P` > "Coverage Gutters: Display Coverage" seç
3. Kod satırlarının yanında renkleri göreceksiniz:
   - 🟢 Yeşil: Test edildi
   - 🔴 Kırmızı: Test edilmedi
   - 🟡 Sarı: Kısmen test edildi

---

## 📁 Test Dosya Yapısı

```
test/
├── unit/                    # Unit testler (hızlı, çok sayıda)
│   ├── models/
│   │   ├── person_test.dart
│   │   ├── skill_test.dart
│   │   └── career_goal_test.dart
│   ├── services/
│   │   ├── error_handler_test.dart
│   │   ├── auth_service_test.dart
│   │   └── career_recommendation_test.dart
│   └── swipe/
│       ├── swipe_filter_mixin_test.dart
│       ├── swipe_action_mixin_test.dart
│       └── swipe_data_mixin_test.dart
│
├── widget/                  # Widget testleri (orta hızlı)
│   ├── error_handler_snackbar_test.dart
│   ├── login_screen_test.dart
│   └── swipe_card_test.dart
│
├── integration/             # Integration testleri (yavaş)
│   ├── auth_flow_test.dart
│   ├── swipe_flow_test.dart
│   └── profile_flow_test.dart
│
├── mocks/                   # Mock sınıflar
│   ├── mock_services.dart
│   └── mock_screens.dart
│
└── TEST_COVERAGE_GUIDE.md  # Bu dosya
```

---

## ✅ Test Türleri

### 1️⃣ Unit Tests (En Önemli)

**Ne test edilir:**

- Models (Person, Skill, CareerGoal, vb.)
- Services (ErrorHandler, AuthService, CareerRecommendation)
- Mixins (SwipeFilterMixin, SwipeActionMixin, SwipeDataMixin)
- Controllers (iş mantığı)
- Utility functions
- Validators

**Avantajlar:**

- ⚡ Çok hızlı
- 🎯 İzole
- 🔍 Kolay debug
- 📈 Coverage'ı hızla artırır

**Örnek:**

```dart
test('ErrorHandler - handles auth error correctly', () {
  // Arrange
  final errorHandler = ErrorHandler();
  final error = FirebaseAuthException(code: 'user-not-found');

  // Act
  final message = errorHandler.handleFirebaseAuthError(error);

  // Assert
  expect(message, 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.');
});
```

### 2️⃣ Widget Tests

**Ne test edilir:**

- Widget'ların görünümü
- Kullanıcı etkileşimleri (tap, scroll, input)
- State değişimleri
- Navigation

**Avantajlar:**

- 🎨 UI test eder
- 👆 User interaction test eder
- ⚡ Integration test'ten hızlı

**Örnek:**

```dart
testWidgets('Login button calls login method', (tester) async {
  // Arrange
  await tester.pumpWidget(LoginScreen());

  // Act
  await tester.enterText(find.byKey(Key('email')), 'test@test.com');
  await tester.tap(find.text('Login'));
  await tester.pump();

  // Assert
  expect(find.text('Loading...'), findsOneWidget);
});
```

### 3️⃣ Integration Tests

**Ne test edilir:**

- Tam user flow'lar
- Firebase entegrasyonu
- Multiple screen navigation
- End-to-end senaryolar

**Avantajlar:**

- 🔄 Gerçek kullanım senaryoları
- 🐛 Entegrasyon hatalarını yakalar

---

## 📈 Coverage Artırma Stratejisi

### Adım 1: Mevcut Coverage'ı Ölç

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Kırmızı (test edilmemiş) alanları belirle!**

### Adım 2: Öncelik Sırası

1. **Critical Business Logic** (en öncelikli)

   - Auth işlemleri
   - Swipe actions (like/dislike/favorite)
   - Payment işlemleri (varsa)

2. **Models**

   - Person, Skill, CareerGoal
   - toJson/fromMap metodları
   - copyWith, equality

3. **Services**

   - ErrorHandler
   - AuthService
   - CareerRecommendationService

4. **Mixins**

   - SwipeFilterMixin
   - SwipeActionMixin
   - SwipeDataMixin

5. **Controllers**

   - AuthController
   - SwipeController
   - ProfileController

6. **Widgets**
   - Custom widgets
   - Reusable components

### Adım 3: Test Yazma Döngüsü

```
1. 🔴 Kırmızı alan seç
2. ✍️ Test yaz
3. ✅ Test'i çalıştır
4. 🔄 Refactor
5. 📊 Coverage kontrol et
6. ♻️ Tekrarla
```

---

## 🎨 Test Yazma Best Practices

### 1. AAA Pattern Kullan

```dart
test('description', () {
  // Arrange (Hazırlık)
  final controller = MyController();
  final input = 'test';

  // Act (Aksiyon)
  final result = controller.process(input);

  // Assert (Doğrulama)
  expect(result, 'expected');
});
```

### 2. Test İsimlendirme

**❌ Kötü:**

```dart
test('test1', () {});
test('should work', () {});
```

**✅ İyi:**

```dart
test('handleFirebaseAuthError - returns correct message for user-not-found', () {});
test('matchesFilters - returns false when user is already processed', () {});
```

### 3. Group Kullan

```dart
group('ErrorHandler - Firebase Auth Errors', () {
  test('user-not-found error', () {});
  test('wrong-password error', () {});
  test('email-already-in-use error', () {});
});
```

### 4. setUp ve tearDown

```dart
late MyController controller;

setUp(() {
  controller = MyController();
  Get.testMode = true;
});

tearDown(() {
  controller.dispose();
  Get.reset();
});
```

### 5. Mock'ları Kullan

```dart
class MockAuthService extends Mock implements AuthService {}

test('with mock', () {
  final mockAuth = MockAuthService();
  when(mockAuth.login(any, any)).thenAnswer((_) async => true);

  // Test with mock
});
```

---

## 🔧 Proje Spesifik Örnekler

### ErrorHandler Test

✅ Tamamlandı: `/test/unit/service/error_handler_test.dart`

**Coverage:** ~90%

### SwipeFilterMixin Test

✅ Tamamlandı: `/test/unit/swipe/swipe_filter_mixin_test.dart`

**Coverage:** ~85%

### Person Model Test

✅ Tamamlandı: `/test/unit/models/person_test.dart`

**Coverage:** ~80%

### Yapılması Gerekenler

- [ ] SwipeActionMixin test
- [ ] SwipeDataMixin test
- [ ] AuthController test (güncelle)
- [ ] CareerRecommendationService test
- [ ] TechEventService test
- [ ] Validation test (genişlet)
- [ ] LoginScreen widget test
- [ ] RegisterScreen widget test
- [ ] SwipeScreen widget test
- [ ] Profile flow integration test

---

## 📊 Coverage Raporunu Okuma

### Rapor Metrikleri

```
Lines: 75%   ← Test edilen kod satırı oranı
Functions: 80%   ← Test edilen fonksiyon oranı
Branches: 70%   ← Test edilen branch (if/else) oranı
```

### Renk Kodları

- 🟢 **Yeşil (80-100%):** Çok iyi!
- 🟡 **Sarı (60-80%):** Kabul edilebilir
- 🟠 **Turuncu (40-60%):** İyileştir
- 🔴 **Kırmızı (0-40%):** Acil test yaz!

---

## 🚨 Yaygın Hatalar ve Çözümleri

### Hata 1: GetX Test Mode

```dart
// ❌ Hata
test('test', () {
  final controller = MyController();
  // GetX hataları...
});

// ✅ Çözüm
test('test', () {
  Get.testMode = true;
  final controller = MyController();
  // Çalışır!
});
```

### Hata 2: Async Test

```dart
// ❌ Hata
test('async test', () {
  final result = await someAsyncFunction();
  expect(result, true);
});

// ✅ Çözüm
test('async test', () async {  // async ekle
  final result = await someAsyncFunction();
  expect(result, true);
});
```

### Hata 3: Firebase Mock

```dart
// Firebase initialization gerekiyor
void main() {
  setupFirebaseMocks();  // Test helper'dan

  test('firebase test', () {});
}
```

---

## 🎯 Coverage Hedeflerine Ulaşma Planı

### Hafta 1-2: Foundation (Temel)

- [x] ErrorHandler unit tests
- [x] Person model tests
- [x] SwipeFilterMixin tests
- [ ] SwipeActionMixin tests
- [ ] SwipeDataMixin tests

**Hedef Coverage:** %40

### Hafta 3-4: Services

- [ ] AuthService tests
- [ ] CareerRecommendationService tests
- [ ] TechEventService tests
- [ ] PushNotificationSystem tests

**Hedef Coverage:** %60

### Hafta 5-6: Controllers & Widgets

- [ ] AuthController tests (mevcut güncelle)
- [ ] HomeController tests
- [ ] SwipeController tests
- [ ] LoginScreen widget tests
- [ ] RegisterScreen widget tests

**Hedef Coverage:** %75

### Hafta 7-8: Integration & Refinement

- [ ] Auth flow integration test
- [ ] Swipe flow integration test
- [ ] Profile flow integration test
- [ ] Edge case tests
- [ ] Performance tests

**Hedef Coverage:** %80+

---

## 📝 Coverage Raporu Filtreleme

Bazı dosyaları coverage'dan hariç tutmak için:

```yaml
# coverage_excludes.yaml
exclude:
  - "**/*.g.dart" # Generated files
  - "**/*.freezed.dart" # Freezed files
  - "**/firebase_options.dart" # Firebase config
  - "lib/main.dart" # Main entry
```

---

## 🤖 CI/CD Entegrasyonu

### GitHub Actions Örneği

```yaml
name: Test Coverage

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: genhtml coverage/lcov.info -o coverage/html
      - uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

---

## 📚 Kaynaklar

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [GetX Testing](https://github.com/jonataslaw/getx#testing)
- [Mockito](https://pub.dev/packages/mockito)

---

## 💡 Pro Tips

1. **Testleri sürekli çalıştır:** `flutter test --watch`
2. **Golden tests kullan:** Görsel regresyon için
3. **Coverage badge ekle:** README'ye
4. **CI'da coverage threshold belirle:** Min %70
5. **Her PR'da coverage kontrol et:** Düşmemeli!

---

## 🎉 Sonuç

Test coverage artırmak:

- 🐛 Bug'ları erken yakalar
- 💪 Güvenle refactor yapmanızı sağlar
- 📖 Canlı dokümantasyon görevi görür
- 🚀 Kod kalitesini artırır

**Hedef:** Her yeni feature için test yaz! 🎯
