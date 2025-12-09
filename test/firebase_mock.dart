import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock method channel responses
  const MethodChannel('plugins.flutter.io/firebase_core')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Firebase#initializeCore':
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': {},
          }
        ];
      case 'Firebase#initializeApp':
        return {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': {},
        };
      default:
        return null;
    }
  });

  // Mock auth method channel responses
  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Auth#signInAnonymously':
        return {
          'user': {
            'uid': 'test-uid',
            'isAnonymous': true,
            'email': null,
            'displayName': null,
          }
        };
      default:
        return null;
    }
  });
}

// Alias for setupFirebaseMocks to support both naming conventions
void setupFirebaseAuthMocks() {
  setupFirebaseMocks();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseMocks();
}

Future<void> setupFirebaseTest() async {
  setupFirebaseMocks();
  await Firebase.initializeApp();
}
